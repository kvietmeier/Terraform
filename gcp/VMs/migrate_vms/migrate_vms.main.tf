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

resource "google_compute_instance_from_machine_image" "vm_instance" {
  provider = google-beta   # use beta provider
  for_each = var.vms

  name         = each.key
  zone         = var.zone
  machine_type = each.value.machine_type

  source_machine_image = each.value.machine_image

  service_account {
    email  = var.service_account.email
    scopes = var.service_account.scopes
  }

  network_interface {
    subnetwork = var.subnet_name
    # ephemeral IP assigned automatically
  }

  metadata = {
    ssh-keys           = "${var.ssh_user}:${local.ssh_key_content}"
    serial-port-enable = true
  }
}
###=====================       End VM Resource Block       =========================###

### Output VM hostnames
output "vm_names" {
  value       = [for vm in google_compute_instance_from_machine_image.vm_instance : vm.name]
  description = "List of VM hostnames"
}
