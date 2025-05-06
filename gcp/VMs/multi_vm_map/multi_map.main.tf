###===================================================================================###
#
#  File:  multi.main.tf
#  Created By: Karl Vietmeier
#
#  Terraform Module Code
#  Purpose:  Create multiple identical VMs from a simple list
#  vm_names             = ["linux01", "linux02", "linux03"]
# 
###===================================================================================###


###===================================================================================###
###                  Start creating infrastructure resources                          ###

# Cloud-Init Configuration
# This block loads the cloud-init configuration that is passed to the VM at boot time.
# It enables automatic configuration like user setup, package installation, etc.
data "cloudinit_config" "system_setup" {
  gzip = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content      = "${local.cloudinit_config}"
    filename     = "conf.yaml"
  }
}


# Google Cloud VM instance with public IP
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
