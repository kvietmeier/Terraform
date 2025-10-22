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
  project = var.project_id
  provider = google-beta
  zone     = var.tpu_zone
}

data "google_tpu_v2_runtime_versions" "available" {
  project = var.project_id
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

###===================================================================================###
#                         TPU Data Disk (Optional)
###===================================================================================###
# Creates a persistent data disk to attach to the TPU VM.
# Useful for workloads requiring large dataset storage or scratch space.

resource "google_compute_disk" "disk" {
  name = "tpu-data-disk-${var.tpu_zone}"
  type = var.tpu_disk_type    # <-- Using variable
  size = var.tpu_disk_size_gb # <-- Using variable
  zone = var.tpu_zone
}


###===================================================================================###
#                         TPU v2 VM Resource
###===================================================================================###
# Defines the TPU node (VM) resource using the google-beta provider.
# This configuration deploys a TPU with specified runtime, accelerator type,
# and networking tied to existing infrastructure.

resource "google_tpu_v2_vm" "tpu" {
  provider         = google-beta
  project = var.project_id

  name             = var.tpu_name
  zone             = var.tpu_zone
  #description      = "Text description of the TPU."
  description      = var.tpu_description

  runtime_version  = var.tpu_runtime 
  #runtime_version  = "tpu-vm-tf-2.13.0" 

  accelerator_type = var.tpu_accelerator_type # <-- Using variable

  cidr_block       = var.tpu_cidr_block

  timeouts {
    create = "60m" # Increase the timeout for the creation operation to 60 minutes
  }

  network_config {
    can_ip_forward      = true
    enable_external_ips = false
    # Reference the existing network and subnet using data sources
    network             = data.google_compute_network.network.self_link
    subnetwork          = data.google_compute_subnetwork.subnet.self_link
  }

  scheduling_config {
    spot = false
  }

  shielded_instance_config {
    enable_secure_boot = false
  }

  service_account {
    # Reference the existing service account using the data source
    email  = var.service_account
  }

  data_disks {
    source_disk = google_compute_disk.disk.id
    mode        = "READ_ONLY"
  }

  /*   
  labels = {
    foo = "bar"
  }

  metadata = {
    foo = "bar"
  }

  tags = ["foo"]
  */

  # Removed the 'time_sleep' dependency as it's generally not needed 
  # when referencing existing network infrastructure via data sources.
}

###===================================================================================###
# End of File
###===================================================================================###