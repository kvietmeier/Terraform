###===================================================================================###
#  File:         tpu_nodes.main.tf
#  Created By:   Karl Vietmeier / VAST Data
#  License:      Licensed under the Apache License, Version 2.0
#                http://www.apache.org/licenses/LICENSE-2.0
#
#  Description:  Main Terraform configuration for TPU node provisioning.
#                Defines providers, data sources (VPC, subnet, service account),
#                and resources for TPU VM and associated data disk creation.
#
#  Source Docs: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/tpu_v2_vm
#
###===================================================================================###

###===================================================================================###
#                        Provider Configuration
###===================================================================================###
# Uses both `google` and `google-beta` providers. 
# The beta provider is required for TPU v2 VM resources.

terraform {
  required_providers {
  google = {
      source  = "hashicorp/google"
      version = ">=5.0.0"
    }
  google-beta = {
      source  = "hashicorp/google-beta"
      version = "7.6.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.tpu_zone
}


###===================================================================================###
#                         Data Sources
###===================================================================================###
# Retrieve existing infrastructure objects to reference in new resource definitions.
# Ensures the TPU node is deployed within an existing, managed environment.

# --- TPU Accelerator and Runtimes (lookup available types in the target zone)
# To view all the options in that region - 
# terraform console
# > data.google_tpu_v2_accelerator_types.available.accelerator_types[*].type
# > data.google_tpu_v2_runtime_versions.available.runtime_versions[*].version

data "google_tpu_v2_accelerator_types" "available" {
  provider = google-beta
  zone     = var.tpu_zone
}

data "google_tpu_v2_runtime_versions" "available" {
  provider = google-beta
  zone     = var.tpu_zone
}


# --- Data Sources (Referencing Existing Infrastructure) ---
# --- Existing VPC Network
data "google_compute_network" "network" {
  name    = var.vpc_name
  project = var.project_id
}

# --- Existing Subnet
data "google_compute_subnetwork" "subnet" {
  name    = var.subnet_name
  region  = var.tpu_region
  project = var.project_id
}

# --- Existing Service Account
# Use account_id by splitting the email to get the short form before '@'
data "google_service_account" "sa" {
  account_id = split("@", var.service_account)[0]
  project    = var.project_id
}
