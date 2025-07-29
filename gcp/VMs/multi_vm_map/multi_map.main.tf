###===================================================================================###
#  File:         multi.main.tf
#  Created By:   Karl Vietmeier / KCV Consulting
#  License:      Licensed under the Apache License, Version 2.0
#                http://www.apache.org/licenses/LICENSE-2.0
#
#  Description:  Terraform module to deploy multiple identical VMs using a simple map
#                of VM names and parameters (e.g., machine type, boot disk, IP octet).
#
#  Purpose:      Automates provisioning of multiple Google Cloud VMs with:
#                   - Cloud-init configuration
#                   - Static IP assignments
#                   - Custom SSH keys
#                   - Service account integration
#
#  Example Input:
#       vm_names = ["linux01", "linux02", "linux03"]
###===================================================================================###


###===================================================================================###
###                  Start creating infrastructure resources                          ###

# Cloud-Init Configuration
# Purpose: Supplies initial OS bootstrap configuration (users, packages, etc.)
# to each VM at first boot using cloud-init.
data "cloudinit_config" "system_setup" {
  gzip = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content      = "${local.cloudinit_config}"
    filename     = "conf.yaml"
  }
}

/* 
 Google Compute VM Instance
 Creates one VM per entry in var.vms map.
 Each VM gets:
   - Defined machine type and boot disk
   - Cloud-init configuration
   - Static private IP based on ip_octet
   - SSH key injection via metadata 
*/
resource "google_compute_instance" "vm_instance" {
  for_each     = var.vms

  name         = each.key
  zone         = var.zone
  machine_type = each.value.machine_type

  boot_disk {
    initialize_params {
      image = each.value.os_image
      size  = each.value.bootdisk_size
    }
  }

  service_account {
    email  = var.service_account.email
    scopes = var.service_account.scopes
  }
  
  network_interface {
    subnetwork    = var.subnet_name
    network_ip    = cidrhost(data.google_compute_subnetwork.my_subnet.ip_cidr_range, each.value.ip_octet)  # Use ip_octet for fourth octet
  }

  metadata = {
    startup-script      = <<-CLOUDINIT
    #!/bin/bash
    sleep 30
    command -v cloud-init &>/dev/null || (dnf install -y cloud-init && reboot)
    CLOUDINIT

    ssh-keys            = "${var.ssh_user}:${local.ssh_key_content}"
    serial-port-enable  = true
    user-data           = "${data.cloudinit_config.system_setup.rendered}"
  }
}


output "vm_private_ips" {
  value = [for vm in google_compute_instance.vm_instance : vm.network_interface[0].network_ip]
  description = "List of private IP addresses of the VMs"
}
