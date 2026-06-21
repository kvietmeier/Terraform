###===============================================================================================###
### Terraform Configuration for GKE Scale-to-Zero Architecture
###===============================================================================================###
# This configuration provisions a single-zone GKE cluster in us-central1-a [cite: 24]
# tailored for compute-heavy AI workloads while maintaining tight budget compliance[cite: 4, 34].
#
# INFRASTRUCTURE SUMMARY:
# - Default Pool: Destroyed immediately upon creation (GKE best practice to isolate critical [cite: 28]
#   control plane infrastructure from volatile workload environments)[cite: 28, 89].
# - System Pool: "system-pool" anchoring core Kubernetes management pods (e.g., kube-dns)[cite: 29, 66].
#   Runs 24/7 utilizing right-sized e2-standard-4 compute nodes, securely scaled to a minimum [cite: 31, 67]
#   of TWO instances to maintain strict site reliability and high availability[cite: 31, 68].
# - Workload Pool: "de-team-pool1" consisting of heavy-duty n4-standard-16 (16 vCPUs) instances [cite: 71, 72]
#   backed by 256GB hyperdisk-balanced boot storage[cite: 73, 74]. Leverages Cluster Autoscaling [cite: 34]
#   mechanisms to automatically terminate instances completely down to ZERO nodes when idle[cite: 34].
# - Metadata & Security: Formally injected with the "vast-client" network target tag to filter 
#   ingress traffic via firewall policy, and stamped with mandatory corporate tracking labels [cite: 77, 83]
#   (longrun=yes, used_by=solutions, owner=solutions) for unified GCP/K8s resource billing[cite: 77, 78, 83].
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
  description = "The target GCP Project ID for infrastructure allocation."
  default     = "techsummit-498311" # [cite: 4325]
}

variable "cluster_name" {
  type        = string
  description = "The unique identifier for the parent GKE cluster."
  default     = "techsummit-de-team" # [cite: 4324]
}

variable "location" {
  type        = string
  description = "The specific compute zone or region where resources are pinned."
  default     = "us-central1-a" # [cite: 4326] (Corrected typo from source 'us-centrall-a')
}

variable "gke_version" {
  type        = string
  description = "The designated Kubernetes control plane version."
  default     = "1.35.5-gke.1000000" # [cite: 4327]
}

variable "vpc_name" {
  type        = string
  description = "The primary VPC network name."
  default     = "summit-vpc" # [cite: 4328]
}

variable "subnet_name" {
  type        = string
  description = "The primary subnetwork interface name identifier."
  default     = "subnet19-us-central1" # [cite: 4329]
}

# ==============================================================================
# 3. PARENT CLUSTER SETUP & TEMPORARY POOL DELETION
# ==============================================================================

resource "google_container_cluster" "primary" {
  name             = var.cluster_name
  location         = var.location
  project          = var.project_id
  min_master_version = var.gke_version

  network    = var.vpc_name
  subnetwork = var.subnet_name

  # CRITICAL SRE PATTERN: Decoupling Default Pool Construction.
  # GKE requires an initial node pool to boot, but we immediately destroy it
  # to isolate the control plane from volatile default sizing configurations.
  remove_default_node_pool = true
  initial_node_count       = 1

  # IP Allocation and Routing Topologies
  ip_allocation_policy {
    # Utilizing Telco Carrier-Grade NAT (CGNAT) to completely bypass RFC 1918 limits
    cluster_ipv4_cidr_block  = "100.64.0.0/21" # [cite: 4331, 4332]
    services_ipv4_cidr_block = "100.64.8.0/27" # [cite: 4333]
  }

  default_snat_status {
    disabled = false
  }

  # Security Hardening: Network isolation settings
  private_cluster_config {
    enable_private_nodes    = true # [cite: 4377]
    enable_private_endpoint = false # Allowed public access to endpoint for administrative operations
    master_ipv4_cidr_block  = "172.16.0.16/28" # [cite: 4334]
  }

  # Cluster Metadata tracking applied across global cloud assets
  resource_labels = {
    longrun = "yes"
    used_by = "solutions"
    owner   = "solutions"
  } # [cite: 4349]

  lifecycle {
    ignore_changes = [
      initial_node_count,
      node_config,
    ]
  }
}

# ==============================================================================
# 4. HIGH AVAILABILITY ANCHOR SYSTEM NODE POOL
# ==============================================================================

resource "google_container_node_pool" "system_pool" {
  name       = "system-pool" # [cite: 4338]
  cluster    = google_container_cluster.primary.name
  location   = google_container_cluster.primary.location
  project    = google_container_cluster.primary.project
  node_count = 2 # [cite: 4340]

  # Node Architecture Configuration
  node_config {
    machine_type = "e2-standard-4" # [cite: 4339]
    disk_size_gb = 100
    disk_type    = "pd-standard"

    # Network Identity Management via Target Tags instead of literal IP filtering
    tags = ["vast-client"] # 

    # Least-Privilege IAM Integration
    # Dev lab defaults to project Owner, but production requires custom service accounts.
    # The default Compute Engine service account is used here for direct equivalence.
    service_account = "default"

    # Labels for infrastructure tracking and scheduling alignment
    labels = {
      longrun = "yes"
      used_by = "solutions"
      owner   = "solutions"
    } # [cite: 4350]

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ==============================================================================
# 5. SCALE-TO-ZERO SANDBOX WORKLOAD NODE POOL
# ==============================================================================

resource "google_container_node_pool" "workload_pool" {
  name       = "de-team-pool1" # [cite: 4343]
  cluster    = google_container_cluster.primary.name
  location   = google_container_cluster.primary.location
  project    = google_container_cluster.primary.project
  
  # Set initial node counts to 0 to align with scale-to-zero parameters
  initial_node_count = 0 # [cite: 4419]

  # Cluster Autoscaler settings enabling cost optimization mechanisms
  autoscaling {
    min_node_count = 0 # [cite: 4415]
    max_node_count = 5 # [cite: 4417]
  }

  node_config {
    machine_type = "n4-standard-16" # [cite: 4344]
    disk_size_gb = 256 # [cite: 4345]
    disk_type    = "hyperdisk-balanced" # [cite: 4346]

    tags = ["vast-client"] # [cite: 4351]

    service_account = "default"

    labels = {
      longrun = "yes"
      used_by = "solutions"
      owner   = "solutions"
    } # [cite: 4350]

    # SRE HARDENING PROTECTION BLOCK: Strict Kubernetes Taints
    # Prevents lightweight, non-critical pods from triggering autoscaler events
    # on expensive enterprise-grade hardware nodes.
    taint {
      key    = "workload" # [cite: 4449, 4486]
      value  = "heavy" # [cite: 4449, 4487]
      effect = "NO_SCHEDULE" # [cite: 4449, 4488]
    }

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }

  # Prevent race conditions by forcing the highly available system anchor online first
  depends_on = [google_container_node_pool.system_pool]
}

# ==============================================================================
# 6. ARCHITECTURAL EXPORTS
# ==============================================================================

output "kubernetes_endpoint" {
  description = "The private or public control plane API connection string."
  value       = google_container_cluster.primary.endpoint
}

output "gcloud_auth_command" {
  description = "Executable diagnostic terminal string to bind kubectl locally."
  value       = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --zone ${google_container_cluster.primary.location} --project ${google_container_cluster.primary.project}"
}