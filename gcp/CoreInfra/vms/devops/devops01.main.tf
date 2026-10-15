###===================================================================================###
#
#  File:         devops01.main.tf
#  Created By:   Karl Vietmeier
#
#  Terraform Module Code
#  Purpose:      Create a VM with basic configuration
# 
#  Files in Module:
#    - devops01.main.tf
#    - devops01.variables.tf
#    - devops01.tfvars
#
###===================================================================================###


###===================================================================================###
#                        Start creating infrastructure resources
###===================================================================================###


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

/*
# Reserve External (Public) IP Address — unused (no public IP)
resource "google_compute_address" "vm_public_ip" {
  name         = var.public_ip_name
  address_type = "EXTERNAL"
  region       = var.region
}

# Reserve Internal (Private) IP Address — unused (cloud-assigned private IP)
resource "google_compute_address" "vm_private_ip" {
  name         = var.private_ip_name
  address_type = "INTERNAL"
  subnetwork   = var.subnet_name
  region       = var.region
  address      = var.private_ip
}
*/

# Google Compute Engine VM Instance
# Private-only NIC; GCP assigns the internal IP from the subnet.
resource "google_compute_instance" "vm_instance" {
  zone         = var.zone
  name         = var.vm_name
  machine_type = var.machine_type

  boot_disk {
    initialize_params {
      image = var.os_image
      size  = var.bootdisk_size
    }
  }

  network_interface {
    subnetwork = var.subnet_name
    # Cloud-assigned private IP — do not set network_ip
    # No access_config — no public IP (use IAP / bastion)
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
  
  service_account {
    email  = var.sa_email
    scopes = var.sa_scopes
  }

  tags   = var.vm_tags
  labels = var.labels
}


###===================       End VM Resource Block       ===================###


###===================              Outputs              ===================###


# No public IP when access_config is omitted.
# output "instance_public_ip" {
#   value = google_compute_address.vm_public_ip.address
# }

# Cloud-assigned internal private IP.
output "instance_private_ip" {
  value = google_compute_instance.vm_instance.network_interface[0].network_ip
}
