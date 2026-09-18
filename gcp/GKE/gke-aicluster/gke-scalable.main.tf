###===============================================================================================###
### Terraform Configuration for GKE Scale-to-Zero Architecture
###===============================================================================================###
# Single-zone GKE cluster (us-central1-a) for compute-heavy AI workloads with scale-to-zero.
#
# NETWORKING (Andromeda / VPC-native — required):
#   One subnet with alias (secondary) ranges. Pod IPs are real VPC addresses, so a VPN that
#   advertises the VPC plan (example: 10.199.0.0/20) can reach Flask/web apps IN the pods.
#
#   Do NOT burn the whole /20 on GKE — that block is the VPC plan for nodes, other apps,
#   and leftover growth. GKE only takes named secondary slices (see variables).
#
# INFRASTRUCTURE SUMMARY:
# - Default pool: created then removed (remove_default_node_pool)
# - system-pool: e2-standard-4 × 2 (always on for kube-dns / system pods)
# - de-team-pool1: n4-standard-16, hyperdisk-balanced, autoscaled 0..5, taint workload=heavy
# - Network tag: vast-client  |  labels: longrun / used_by / owner = solutions
###===============================================================================================###


# ==============================================================================
# 1. TERRAFORM INITIALIZATION & PROVIDERS
# ==============================================================================

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = "us-central1"
}

# ==============================================================================
# 2. VARIABLES & PARAMETERIZATION
# ==============================================================================

variable "project_id" {
  type        = string
  description = "GCP project ID."
  default     = "techsummit-498311"
}

variable "cluster_name" {
  type        = string
  description = "GKE cluster name."
  default     = "techsummit-de-team"
}

variable "location" {
  type        = string
  description = "Zone (or region) for the cluster."
  default     = "us-central1-a"
}

variable "gke_version" {
  type        = string
  description = "Optional min control-plane version (e.g. 1.30.5-gke.1014001). Empty = GKE default for the channel/location. Validate with: gcloud container get-server-config --zone=us-central1-a"
  default     = ""
}

variable "vpc_name" {
  type        = string
  description = "VPC network name."
  default     = "summit-vpc"
}

variable "subnet_name" {
  type        = string
  description = "Single subnet that holds node primary IPs + GKE alias (secondary) ranges."
  default     = "subnet19-us-central1"
}

# --- VPC address plan (example) — advertise 10.199.0.0/20 over VPN ---
# Only GKE's secondary slices are referenced here. Primary + leftovers stay for other apps.
# These named secondaries MUST already exist on var.subnet_name (CoreInfra vpcs/core supports them).

variable "pods_secondary_range_name" {
  type        = string
  description = "Subnet secondary range name for Pod (alias) IPs."
  default     = "gke-pods"
}

variable "services_secondary_range_name" {
  type        = string
  description = "Subnet secondary range name for Service ClusterIPs."
  default     = "gke-services"
}

variable "master_ipv4_cidr_block" {
  type        = string
  description = "Private control-plane /28 — must not overlap the VPC plan or secondaries."
  default     = "172.16.0.16/28"
}

# Documentation-only defaults (must match what you put on the subnet):
#   VPC plan (VPN):     10.199.0.0/20
#   Subnet primary:     10.199.0.0/24     nodes + other VMs/apps on this subnet
#   gke-pods:           10.199.8.0/22     alias IPs — Flask/web pods (VPN-reachable)
#   gke-services:       10.199.12.0/24    ClusterIPs (cluster-local; still carved from plan)
#   leftover in /20:    10.199.1–7, 13–15 for other subnets/apps/growth

# ==============================================================================
# 3. PARENT CLUSTER — VPC-NATIVE (ANDROMEDA) ON ONE SUBNET
# ==============================================================================

resource "google_container_cluster" "primary" {
  name               = var.cluster_name
  location           = var.location
  project            = var.project_id
  min_master_version = var.gke_version != "" ? var.gke_version : null

  network    = var.vpc_name
  subnetwork = var.subnet_name

  # Provider 5.x defaults this to true — set false for lab destroy convenience.
  deletion_protection = false

  remove_default_node_pool = true
  initial_node_count       = 1

  # RIGHT WAY: named alias ranges on the SAME subnet (Andromeda / VPC-native).
  # Pod IPs come from gke-pods — VPN clients that route 10.199.0.0/20 can hit Flask/web in-pod.
  # Do not use routes-based clusters; do not auto-carve unmanaged CIDRs that collide with the plan.
  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_secondary_range_name
    services_secondary_range_name = var.services_secondary_range_name
  }

  default_snat_status {
    disabled = false
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  # Private nodes need Cloud NAT (and usually Private Google Access) on this subnet —
  # expect that from CoreInfra VPC/NAT, not created here.

  resource_labels = {
    longrun = "yes"
    used_by = "solutions"
    owner   = "solutions"
  }

  lifecycle {
    ignore_changes = [
      initial_node_count,
      node_config,
    ]
  }
}

# ==============================================================================
# 4. SYSTEM NODE POOL (always on)
# ==============================================================================

resource "google_container_node_pool" "system_pool" {
  name       = "system-pool"
  cluster    = google_container_cluster.primary.name
  location   = google_container_cluster.primary.location
  project    = google_container_cluster.primary.project
  node_count = 2

  node_config {
    machine_type = "e2-standard-4"
    disk_size_gb = 100
    disk_type    = "pd-standard"

    tags = ["vast-client"]

    # Omit service_account → default Compute Engine SA.
    # Do not set service_account = "default" (invalid for the API).

    labels = {
      longrun = "yes"
      used_by = "solutions"
      owner   = "solutions"
    }

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ==============================================================================
# 5. WORKLOAD POOL (scale-to-zero)
# ==============================================================================

resource "google_container_node_pool" "workload_pool" {
  name               = "de-team-pool1"
  cluster            = google_container_cluster.primary.name
  location           = google_container_cluster.primary.location
  project            = google_container_cluster.primary.project
  initial_node_count = 0

  autoscaling {
    min_node_count = 0
    max_node_count = 5
  }

  node_config {
    machine_type = "n4-standard-16"
    disk_size_gb = 256
    disk_type    = "hyperdisk-balanced"

    tags = ["vast-client"]

    labels = {
      longrun = "yes"
      used_by = "solutions"
      owner   = "solutions"
    }

    taint {
      key    = "workload"
      value  = "heavy"
      effect = "NO_SCHEDULE"
    }

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }

  depends_on = [google_container_node_pool.system_pool]
}

# ==============================================================================
# 6. OUTPUTS
# ==============================================================================

output "kubernetes_endpoint" {
  description = "Control plane API endpoint."
  value       = google_container_cluster.primary.endpoint
  sensitive   = true
}

output "gcloud_auth_command" {
  description = "Configure kubectl for this cluster."
  value       = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --zone ${google_container_cluster.primary.location} --project ${google_container_cluster.primary.project}"
}

output "networking_reminder" {
  description = "Expected subnet alias layout (must exist before apply)."
  value       = <<-EOT
    VPC plan (VPN-advertised): 10.199.0.0/20  — whole VPC, not all for GKE
    Subnet ${var.subnet_name} on ${var.vpc_name}:
      primary:              nodes + other apps on this subnet (e.g. 10.199.0.0/24)
      ${var.pods_secondary_range_name}:     e.g. 10.199.8.0/22   ← Flask/web pod alias IPs (VPN-reachable)
      ${var.services_secondary_range_name}: e.g. 10.199.12.0/24  ← Service ClusterIPs
    Leftover in /20: other subnets / apps / growth
  EOT
}
