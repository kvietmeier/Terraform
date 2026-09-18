###===============================================================================================###
### Terraform Configuration for GKE Scale-to-Zero Architecture
###===============================================================================================###
# COST RULE:
#   - GPU / TPU / CPU-heavy pools: scale-from-zero ONLY (min=0). No idle accelerators.
#   - system-pool: always-on (kube-system only) — cheapest necessary spend.
#   - apps-pool: low-end general-purpose STAGING area (Flask, VAST I/O, smoke tests)
#     before moving workloads to GPU/TPU. Default min=0; set apps_min_nodes=1 only if
#     you accept a tiny always-on staging floor.
#
# Devs: target pool=apps first → prove VAST/app path → then retarget GPU/TPU + timers.
#
# NETWORKING (Andromeda / VPC-native — required):
#   One subnet with alias ranges. VPN plan example 10.199.0.0/20 is whole VPC — don't
#   burn it all on GKE; carve modest gke-pods / gke-services secondaries.
#
# POOLS:
# - system-pool: e2-standard-4 (kube-system)
# - apps-pool:   e2-standard-2 staging (VAST I/O, basic apps) — default min=0
# - de-team-pool1 / gpu-l4-pool: expensive, min=0 always
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
# 2. VARIABLES
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
  description = "Optional min control-plane version. Empty = GKE default. Validate: gcloud container get-server-config --zone=us-central1-a"
  default     = ""
}

variable "vpc_name" {
  type        = string
  description = "VPC network name."
  default     = "summit-vpc"
}

variable "subnet_name" {
  type        = string
  description = "Single subnet: node primary + GKE alias (secondary) ranges."
  default     = "subnet19-us-central1"
}

variable "pods_secondary_range_name" {
  type        = string
  description = "Subnet secondary range name for Pod alias IPs."
  default     = "gke-pods"
}

variable "services_secondary_range_name" {
  type        = string
  description = "Subnet secondary range name for Service ClusterIPs."
  default     = "gke-services"
}

variable "master_ipv4_cidr_block" {
  type        = string
  description = "Private control-plane /28 — must not overlap the VPC plan."
  default     = "172.16.0.16/28"
}

variable "system_node_count" {
  type        = number
  description = "Only always-on nodes (system pool). Use 1 for max lab savings; 2 for system-pod HA."
  default     = 1
}

variable "enable_apps_pool" {
  type        = bool
  description = "Low-end apps/staging pool (VAST I/O, Flask, smoke tests before GPU/TPU)."
  default     = true
}

variable "apps_machine_type" {
  type        = string
  description = "Cheap general-purpose SKU for staging apps."
  default     = "e2-standard-2"
}

variable "apps_min_nodes" {
  type        = number
  description = "Apps pool min. Keep 0 (no idle). Set 1 only for a tiny always-on staging floor."
  default     = 0
}

variable "apps_max_nodes" {
  type        = number
  description = "Apps pool max nodes."
  default     = 3
}

variable "enable_cpu_heavy_pool" {
  type        = bool
  description = "n4 CPU pool, scale-from-zero."
  default     = true
}

variable "enable_gpu_l4_pool" {
  type        = bool
  description = "L4 GPU pool, scale-from-zero (no idle GPUs)."
  default     = true
}

variable "cpu_heavy_max_nodes" {
  type        = number
  description = "Max nodes for CPU heavy pool (min is always 0)."
  default     = 5
}

variable "gpu_l4_max_nodes" {
  type        = number
  description = "Max nodes for L4 GPU pool (min is always 0)."
  default     = 4
}

# Doc carve (must match subnet secondaries before apply):
#   VPC plan (VPN): 10.199.0.0/20
#   primary:        10.199.0.0/24
#   gke-pods:       10.199.8.0/22
#   gke-services:   10.199.12.0/24

# ==============================================================================
# 3. CLUSTER — VPC-NATIVE ON ONE SUBNET
# ==============================================================================

resource "google_container_cluster" "primary" {
  name               = var.cluster_name
  location           = var.location
  project            = var.project_id
  min_master_version = var.gke_version != "" ? var.gke_version : null

  network    = var.vpc_name
  subnetwork = var.subnet_name

  deletion_protection = false

  remove_default_node_pool = true
  initial_node_count       = 1

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

  # Private nodes need Cloud NAT + Private Google Access on the subnet (CoreInfra).

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
# 4. SYSTEM POOL — only permitted always-on spend
# ==============================================================================

resource "google_container_node_pool" "system_pool" {
  name       = "system-pool"
  cluster    = google_container_cluster.primary.name
  location   = google_container_cluster.primary.location
  project    = google_container_cluster.primary.project
  node_count = var.system_node_count

  node_config {
    machine_type = "e2-standard-4"
    disk_size_gb = 100
    disk_type    = "pd-standard"
    tags         = ["vast-client"]

    labels = {
      longrun = "yes"
      used_by = "solutions"
      owner   = "solutions"
      pool    = "system"
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
# 5. APPS / STAGING — low-end GP before GPU/TPU (VAST I/O, Flask, smoke tests)
# ==============================================================================
# Prefer min=0. Optional apps_min_nodes=1 = small always-on staging floor only.

resource "google_container_node_pool" "apps" {
  count = var.enable_apps_pool ? 1 : 0

  name               = "apps-pool"
  cluster            = google_container_cluster.primary.name
  location           = google_container_cluster.primary.location
  project            = google_container_cluster.primary.project
  initial_node_count = var.apps_min_nodes

  autoscaling {
    min_node_count = var.apps_min_nodes
    max_node_count = var.apps_max_nodes
  }

  node_config {
    machine_type = var.apps_machine_type
    disk_size_gb = 50
    disk_type    = "pd-standard"
    # vast-client: same firewall path as other lab nodes talking to VAST
    tags         = ["vast-client"]

    labels = {
      longrun     = "yes"
      used_by     = "solutions"
      owner       = "solutions"
      pool        = "apps"
      accelerator = "none"
      tier        = "staging"
    }

    # Soft preference: apps land here; GPU/CPU-heavy stay on their tainted pools.
    # No NoSchedule taint so default pods can use this as the staging area.
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }

  depends_on = [google_container_node_pool.system_pool]
}

# ==============================================================================
# 6. CPU HEAVY — scale-from-zero (mandatory min=0)
# ==============================================================================

resource "google_container_node_pool" "workload_pool" {
  count = var.enable_cpu_heavy_pool ? 1 : 0

  name               = "de-team-pool1"
  cluster            = google_container_cluster.primary.name
  location           = google_container_cluster.primary.location
  project            = google_container_cluster.primary.project
  initial_node_count = 0

  autoscaling {
    min_node_count = 0 # MANDATORY — no idle CPU heavy nodes
    max_node_count = var.cpu_heavy_max_nodes
  }

  node_config {
    machine_type = "n4-standard-16"
    disk_size_gb = 256
    disk_type    = "hyperdisk-balanced"
    tags         = ["vast-client"]

    labels = {
      longrun     = "yes"
      used_by     = "solutions"
      owner       = "solutions"
      pool        = "cpu-heavy"
      accelerator = "none"
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
# 7. GPU L4 — scale-from-zero (mandatory min=0)
# ==============================================================================
# Pool is declared in Terraform; VMs stay at 0 until a matching GPU pod is pending.

resource "google_container_node_pool" "gpu_l4" {
  count = var.enable_gpu_l4_pool ? 1 : 0

  name               = "gpu-l4-pool"
  cluster            = google_container_cluster.primary.name
  location           = google_container_cluster.primary.location
  project            = google_container_cluster.primary.project
  initial_node_count = 0

  autoscaling {
    min_node_count = 0 # MANDATORY — no idle GPUs
    max_node_count = var.gpu_l4_max_nodes
  }

  node_config {
    machine_type = "g2-standard-8"
    disk_size_gb = 200
    disk_type    = "pd-balanced"
    image_type   = "COS_CONTAINERD"
    tags         = ["vast-client"]

    guest_accelerator {
      type  = "nvidia-l4"
      count = 1
      gpu_driver_installation_config {
        gpu_driver_version = "DEFAULT"
      }
    }

    labels = {
      longrun     = "yes"
      used_by     = "solutions"
      owner       = "solutions"
      pool        = "gpu-l4"
      accelerator = "l4"
    }

    taint {
      key    = "nvidia.com/gpu"
      value  = "present"
      effect = "NO_SCHEDULE"
    }

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }

  depends_on = [google_container_node_pool.system_pool]
}

# ==============================================================================
# 8. OUTPUTS
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

output "cost_model" {
  description = "How this cluster saves money."
  value       = <<-EOT
    Always-on: system-pool × ${var.system_node_count} (kube-system only).
    Staging:   apps-pool (${var.apps_machine_type}) min=${var.apps_min_nodes} max=${var.apps_max_nodes}
               — VAST I/O / Flask / smoke tests BEFORE GPU/TPU. Prefer min=0.
    Scale-from-zero: CPU heavy=${var.enable_cpu_heavy_pool}, GPU L4=${var.enable_gpu_l4_pool}.
    Flow: prove on apps-pool → then retarget GPU/TPU + use examples/ timers so nodes → 0.
  EOT
}

output "networking_reminder" {
  description = "Expected subnet alias layout (must exist before apply)."
  value       = <<-EOT
    VPC plan (VPN): 10.199.0.0/20 — whole VPC, not all for GKE
    Subnet ${var.subnet_name}:
      primary:              e.g. 10.199.0.0/24
      ${var.pods_secondary_range_name}:     e.g. 10.199.8.0/22
      ${var.services_secondary_range_name}: e.g. 10.199.12.0/24
  EOT
}
