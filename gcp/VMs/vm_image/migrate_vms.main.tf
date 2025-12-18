###===================================================================================###
#  File:         multi.main.tf
#  Created By:   Karl Vietmeier / KCV Consulting
#  License:      Licensed under the Apache License, Version 2.0
#                http://www.apache.org/licenses/LICENSE-2.0
#
#  Description:  Deploys multiple VMs in GCP from prebuilt machine images.
#
#  Purpose:
#    - Simplify migration of existing client VMs across zones/regions
#    - Eliminate the need for cloud-init since the VMs are already configured
#    - Ensure VM hostnames remain consistent (client01–client11)
#
#  Assumptions:
#    - Required machine images (client01-img, client02-img, etc.) have already
#      been created and exist in the project.
#    - The **google-beta provider** must be used, because
#      `google_compute_instance_from_machine_image` is not available
#      in the GA provider.
#
#  Notes:
#    - `source_machine_image` enables reusing captured machine images
#      instead of provisioning from public OS images.
#    - Networking uses the provided subnetwork; IPs are ephemeral unless
#      otherwise managed by Terraform or GCP.
#
#  Example Workflow:
#    1. Capture images from source VMs (done once)
#    2. Destroy old VMs with Terraform
#    3. Redeploy in new zone(s) using these machine images
###===================================================================================###

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
      version = ">= 5.0.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}



###===================================================================================###
#                       Create VMs from Machine Images
###===================================================================================###
###===================================================================================###
#                 Create VMs from Machine Images (FIXED)
###===================================================================================###

resource "google_compute_instance_from_machine_image" "vm_instance" {
  provider = google-beta
  for_each = var.vms

  name         = each.key
  # Using the zone from the variable file (e.g., europe-west4-b)
  zone         = var.zone 
  machine_type = each.value.machine_type

  source_machine_image = each.value.machine_image

  service_account {
    email  = var.service_account.email
    # FIX 1: Must use 'scopes' (plural) to match variable definition
    scopes = var.service_account.scopes 
  }

  network_interface {
    # FIX 2: Construct the full subnetwork URL to avoid scope mismatch
    subnetwork = format(
      "projects/%s/regions/%s/subnetworks/%s",
      var.project_id,
      # Extract the region from the zone variable (e.g., europe-west4-b -> europe-west4)
      substr(var.zone, 0, length(var.zone) - 2),
      var.subnet_name
    )
    # ephemeral IP assigned automatically
  }

/*   # FIX 3: Explicitly define the boot disk to ensure configuration consistency
  # The Machine Image handles the *content*, but this ensures size/type if needed.
  boot_disk {
    disk_size_gb = each.value.bootdisk_size
  }
 */
  metadata = {
    ssh-keys           = "${var.ssh_user}:${local.ssh_key_content}"
    serial-port-enable = true
  }
}