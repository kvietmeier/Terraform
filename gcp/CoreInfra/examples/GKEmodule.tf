#### License

``` text
SPDX-License-Identifier: Apache-2.0
```
###  GKE Cluster

Description

---

#### Notes

APIs:
You need these APIs enabled:

* Kubernetes Engine - container.googleapis.com
* IAM - iam.googleapis.com
* Storage - storage.googleapis.com

---

#### My code is Built With

* [Visual Studio Code](https://code.visualstudio.com/) - Editor
* [Terraform](https://www.terraform.io/) - Terraform

#### All run under PowerShell on Windows 11

* [Windows Terminal](https://docs.microsoft.com/en-us/windows/terminal/) - Console

#### Author/s

* **Karl Vietmeier**

#### License

This project is licensed under the Apache License - see the [LICENSE.md](LICENSE.md) file for details

#### Acknowledgments

* None so far other than the many good examples out there.
###===================================================================================###
#
#  File:  iam.tf
#  Created By: Karl Vietmeier
#
#  Terraform Module Code
#  Purpose:  Blank Template for extra resources
# 
###===================================================================================###


###===================================================================================###
#     Start creating resources
###===================================================================================###

# Google Cloud Service Account for GKE to access GCS
resource "google_service_account" "gke_gcs_access_sa" {
  account_id   = "gke-gcs-access-sa"
  display_name = "GKE Service Account for GCS Access"
  project      = var.project_id
}

# Grant the Service Account the necessary permissions to access the GCS bucket
resource "google_project_iam_member" "gke_gcs_access_sa_storage_bucket_access" {
  project = var.project_id
  role    = "roles/storage.objectAdmin" # Or roles/storage.objectViewer, roles/storage.objectCreator, etc.
  member  = "serviceAccount:${google_service_account.gke_gcs_access_sa.email}"
}
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
###===================================================================================###
#
#  File:  iam.tf
#  Created By: Karl Vietmeier
#
#  Terraform Module Code
#  Purpose:  Blank Template for extra resources
# 
###===================================================================================###


# Output the cluster name for easy access
output "cluster_name" {
  value       = google_container_cluster.primary.name
  description = "The name of the GKE cluster."
}

# Output the cluster location
output "cluster_location" {
  value       = google_container_cluster.primary.location
  description = "The location of the GKE cluster."
}

# Output kubeconfig instructions
output "kubeconfig_instructions" {
  value = "To connect to your cluster, run: gcloud container clusters get-credentials ${google_container_cluster.primary.name} --region ${google_container_cluster.primary.location} --project ${var.project_id}"
  description = "Instructions to configure kubectl for the GKE cluster."
}

output "gke_gcs_access_sa_email" {
  value       = google_service_account.gke_gcs_access_sa.email
  description = "Email of the GSA for GKE GCS access."
}###===================================================================================###
#
#  File:  provider.tf
#  Created By: Karl Vietmeier
#
#  Purpose: Configure the GCP TerraForm Provider 
# 
###===================================================================================###


terraform {
  required_providers {
  google = {
      source  = "hashicorp/google"
      version = "4.74.0"
    }
  }
}

# Set these vars
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}###===================================================================================###
#
#  File:  terraform.tfvars
#  Created By: Karl Vietmeier
#
#  This is a "sanitized" version of the terraform.tfvars file that is excluded from the repo. 
#  Any values that aren't sensitive are left defined, amy sensitive values are stubbed out.
#
#  Edit as required
#
###===================================================================================###


###---  Standard Values
# Project Info
project_id      = "clouddev-itdesk124"
region          = "us-west2"
zone            = "us-west2-a"

# VPC Config
vpc_name        = "karlv-corevpc"
subnet_name     = "subnet-hub-us-west2"


###======  Examples:
cluster_name  = "gketesting01"
gke_num_nodes = 2###===================================================================================###
#
#  File:  variables.tf
#  Created By: Karl Vietmeier
#
#  Variable definitions with defaults
#
###===================================================================================###


### Provider Settings
variable "region" {
  description = "Region to deploy resources"
}

variable "zone" {
  description = "Availbility Zone"
}

variable "project_id" {
  description = "GCP Project ID"
}

variable "vpc_name" {
  description = "VPC to use"
  default     = "default"
}

variable "subnet_name" {
  description = "Subnet to use"
  default     = "default"
}

### GKE Cluster Vars
variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
  default     = "gcs-gke-cluster"
}

variable "gke_username" {
  default     = ""
  description = "gke username"
}

variable "gke_password" {
  default     = ""
  description = "gke password"
}

variable "gke_num_nodes" {
  default     = 2
  description = "number of gke nodes"
}
