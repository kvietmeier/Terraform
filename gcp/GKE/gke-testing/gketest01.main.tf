###===================================================================================###
#
#  File:  gke.main.tf
#  Created By: Karl Vietmeier
#
#  Terraform Module Code
#  Purpose:  Create a basic GKE Cluster  
# 
###===================================================================================###

data "google_container_engine_versions" "gke_version" {
  location = var.region
  version_prefix = "1.27."
}

###===================================================================================###
#     Start creating infrastructure resources
###===================================================================================###

# GKE Cluster
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.region
  project  = var.project_id

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  # Optional: Network configuration
  network    = var.vpc_name
  subnetwork = var.subnet_name
}

# Separately Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name       = google_container_cluster.primary.name
  location   = var.region
  cluster    = google_container_cluster.primary.name
  
  version    = data.google_container_engine_versions.gke_version.release_channel_default_version["STABLE"]
  node_count = var.gke_num_nodes

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = var.project_id
    }

    # preemptible  = true
    machine_type = "n1-standard-1"
    tags         = ["gke-node", "${var.project_id}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}
