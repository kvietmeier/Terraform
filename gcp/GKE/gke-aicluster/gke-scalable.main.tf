###===============================================================================================###
### Terraform Configuration for GKE Scale-to-Zero Architecture
###===============================================================================================###
# This configuration provisions a single-zone GKE cluster in us-central1-a 
# tailored for compute-heavy AI workloads. 
#
# INFRASTRUCTURE SUMMARY:
# - Default Pool: Destroyed immediately upon creation (GKE best practice).
# - Custom Pool: "de-team-pool1" consisting of 5 heavy-duty nodes.
# - Hardware: n4-standard-48 (48 vCPUs) with 256GB hyperdisk-balanced storage.
# ==============================================================================

terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

###===============================================================================================###
### Variables
###===============================================================================================###

variable "project_id" {
  type    = string
  default = "techsummit-498311"
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "zone" {
  type    = string
  default = "us-central1-a"
}

variable "cluster_name" {
  type    = string
  default = "techsummit-de-team"
}

variable "cluster_version" {
  type    = string
  default = "1.35.5-gke.1000000"
}

# Shared Metadata Maps
variable "compliance_labels" {
  type = map(string)
  default = {
    longrun = "yes"
    used_by = "solutions"
    owner   = "solutions"
  }
}

###===============================================================================================###
### GKE Cluster Core Control Plane
###===============================================================================================###

resource "google_container_cluster" "primary" {
  name             = var.cluster_name
  location         = var.zone
  min_master_version = var.cluster_version
  
  # 1. Apply global tracking metadata to the root cluster object
  resource_labels = var.compliance_labels

  # 2. Safety Routine: Automatically drop the default pool immediately upon creation
  remove_default_node_pool = true
  initial_node_count       = 1

  # Optional but recommended network structuring
  deletion_protection = false 
}

###===============================================================================================###
### Node Pool 1: Lightweight System Anchor Pool
###===============================================================================================###

resource "google_container_node_pool" "system_pool" {
  name       = "system-pool"
  cluster    = google_container_cluster.primary.id
  location   = var.zone
  node_count = 1

  node_config {
    machine_type = "e2-standard-2"
    image_type   = "COS_CONTAINERD"

    # Bridges compliance data down to GCP Compute Engine VMs/Disks
    resource_labels = var.compliance_labels

    # Bridges compliance metadata natively directly into kubectl labels
    metadata = {
      "disable-legacy-endpoints" = "true"
      "node-labels"              = "longrun=yes,used_by=solutions,owner=solutions"
    }
  }
}

###===============================================================================================###
### Node Pool 2: Heavy AI/Workload Scale-to-Zero Pool
###===============================================================================================###

resource "google_container_node_pool" "workload_pool" {
  name     = "de-team-pool1"
  cluster  = google_container_cluster.primary.id
  location = var.zone

  # 1. Native Scale-to-Zero Blueprint configuration
  autoscaling {
    min_node_count = 0
    max_node_count = 3
  }

  node_config {
    machine_type = "n4-standard-48"
    image_type   = "COS_CONTAINERD"
    
    # Storage Engine Configuration
    disk_type    = "hyperdisk-balanced"
    disk_size_gb = 256

    # Network tags mapped directly for firewall rule selection
    tags = ["voc-client"]

    # Bridges compliance data down to GCP Compute Engine VMs/Disks
    resource_labels = var.compliance_labels

    # Bridges compliance metadata natively directly into kubectl labels
    metadata = {
      "disable-legacy-endpoints" = "true"
      "node-labels"              = "longrun=yes,used_by=solutions,owner=solutions"
    }
  }

  # Ensure the system-pool initializes first to prevent cluster scheduling issues
  depends_on = [google_container_node_pool.system_pool]
}