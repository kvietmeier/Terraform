###===================================================================================###
#  File:         multi.main.tf
#  Created By:   Karl Vietmeier / KCV Consulting
#  License:      Licensed under the Apache License, Version 2.0
#                http://www.apache.org/licenses/LICENSE-2.0
#


###===================================================================================###
#                        Provider Configuration
###===================================================================================###

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
#                       Create VMs from Machine Images
###===================================================================================###

/* 
data "google_tpu_v2_runtime_versions" "available" {
  provider = google-beta
}

data "google_tpu_v2_accelerator_types" "available" {
  provider = google-beta
}
*/

data "google_tpu_v2_accelerator_types" "available" {
  provider = google-beta
  zone     = var.tpu_zone
}

# --- Data Sources (Referencing Existing Infrastructure) ---
# 1. Fetch existing VPC Network
data "google_compute_network" "network" {
  name    = var.vpc_name
  project = var.project_id
}

# 2. Fetch existing Subnet
data "google_compute_subnetwork" "subnet" {
  name    = var.subnet_name
  region  = var.tpu_region
  project = var.project_id
}

# 3. Fetch existing Service Account
data "google_service_account" "sa" {
  # FIX: Use 'account_id' (the expected argument) and extract the short ID
  #      by splitting the full email string at the '@' symbol and taking the first element (index 0).
  account_id = split("@", var.service_account)[0]
  #id = var.service_account
  # The project is also necessary for a complete lookup
  project    = var.project_id
# --- New Infrastructure: Data Disk (Optional, but kept for completeness) ---
}

resource "google_compute_disk" "disk" {
  name = "tpu-data-disk-${var.tpu_zone}"
  type = var.tpu_disk_type    # <-- Using variable
  size = var.tpu_disk_size_gb # <-- Using variable
  zone = var.tpu_zone
}


# --- The TPU VM Resource ---

resource "google_tpu_v2_vm" "tpu" {
  provider         = google-beta

  name             = var.tpu_name
  zone             = var.tpu_zone
  #description      = "Text description of the TPU."
  description      = var.tpu_description

  runtime_version  = var.tpu_runtime 
  #runtime_version  = "tpu-vm-tf-2.13.0" 

  accelerator_type = var.tpu_accelerator_type # <-- Using variable

  cidr_block       = "172.11.1.0/29" # Ensure this range does NOT conflict with your existing VPC/Subnet ranges

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

  labels = {
    foo = "bar"
  }

  metadata = {
    foo = "bar"
  }

  tags = ["foo"]
  
  # Removed the 'time_sleep' dependency as it's generally not needed 
  # when referencing existing network infrastructure via data sources.
}