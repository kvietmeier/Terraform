# ==============================================================================
# GKE CLUSTER DEPLOYMENT: techsummit-de-team
# ==============================================================================
# This configuration provisions a single-zone GKE cluster in us-central1-a 
# tailored for compute-heavy AI workloads. 
#
# INFRASTRUCTURE SUMMARY:
# - Default Pool: Destroyed immediately upon creation (GKE best practice).
# - Custom Pool: "de-team-pool1" consisting of 5 heavy-duty nodes.
# - Hardware: n4-standard-48 (48 vCPUs) with 256GB hyperdisk-balanced storage.
# ==============================================================================

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# ------------------------------------------------------------------------------
# VARIABLES (Mapped from Bash)
# ------------------------------------------------------------------------------
locals {
  # Cluster Vars
  cluster_name         = "techsummit-de-team"
  project_id           = "techsummit-498311"
  location             = "us-central1-a"
  default_machine_type = "n4-standard-16"
  default_node_count   = 5
  cluster_version      = "1.35.5-gke.1000000"

  # Pool 1 Vars
  pool1_name           = "de-team-pool1"
  pool1_machine_type   = "n4-standard-48"
  pool1_node_count     = 5
  pool1_disk_size      = 256
  pool1_disk_type      = "hyperdisk-balanced"
}

provider "google" {
  project = local.project_id
  region  = "us-central1"
}

# Dynamically fetch project information to get the missing Project Number
data "google_project" "current" {
  project_id = local.project_id
}

# ------------------------------------------------------------------------------
# IAM POLICY BINDING
# ------------------------------------------------------------------------------
resource "google_project_iam_member" "gke_default_sa_role" {
  project = local.project_id
  role    = "roles/container.defaultNodeServiceAccount"
  member  = "serviceAccount:${data.google_project.current.number}-compute@developer.gserviceaccount.com"
}

# ------------------------------------------------------------------------------
# GKE CLUSTER (Includes the default node pool)
# ------------------------------------------------------------------------------
resource "google_container_cluster" "primary" {
  name               = local.cluster_name
  project            = local.project_id
  location           = local.location
  min_master_version = local.cluster_version

  # Setting the initial node count applies to the default node pool 
  initial_node_count = local.default_node_count

  node_config {
    machine_type    = local.default_machine_type
    service_account = "${data.google_project.current.number}-compute@developer.gserviceaccount.com"
  }

  # Ensure the IAM role is bound before spinning up the nodes
  depends_on = [google_project_iam_member.gke_default_sa_role]
}

# ------------------------------------------------------------------------------
# CUSTOM NODE POOL 1
# ------------------------------------------------------------------------------
resource "google_container_node_pool" "pool1" {
  name       = local.pool1_name
  project    = local.project_id
  location   = local.location
  cluster    = google_container_cluster.primary.name
  node_count = local.pool1_node_count

  node_config {
    machine_type = local.pool1_machine_type
    disk_size_gb = local.pool1_disk_size
    disk_type    = local.pool1_disk_type
    
    # Best practice: explicitly define the service account for the nodes
    service_account = "${data.google_project.current.number}-compute@developer.gserviceaccount.com"
  }
}