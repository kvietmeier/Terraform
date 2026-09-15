###===================================================================================###
#  Module: vms/linux
#  Adapted from gcp/CoreInfra/vms/devops
###===================================================================================###

locals {
  ssh_key_content  = file(var.ssh_key_file)
  cloudinit_config = file(var.cloudinit_configfile)
}

data "cloudinit_config" "system_setup" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content      = local.cloudinit_config
    filename     = "conf.yaml"
  }
}

resource "google_compute_address" "vm_public_ip" {
  name         = var.public_ip_name
  address_type = "EXTERNAL"
  region       = var.region
}

resource "google_compute_address" "vm_private_ip" {
  name         = var.private_ip_name
  address_type = "INTERNAL"
  subnetwork   = var.subnet
  region       = var.region
  address      = var.private_ip
}

resource "google_compute_instance" "vm_instance" {
  zone         = var.zone
  name         = var.vm_name
  machine_type = var.machine_type
  project      = var.project_id

  boot_disk {
    initialize_params {
      image = var.os_image
      size  = var.bootdisk_size
    }
  }

  network_interface {
    subnetwork = var.subnet
    network_ip = google_compute_address.vm_private_ip.address

    dynamic "access_config" {
      for_each = var.assign_public_ip ? [1] : []
      content {
        nat_ip = google_compute_address.vm_public_ip.address
      }
    }
  }

  metadata = {
    startup-script = <<-CLOUDINIT
    #!/bin/bash
    sleep 30
    command -v cloud-init &>/dev/null || (dnf install -y cloud-init && reboot)
    CLOUDINIT

    ssh-keys           = "${var.ssh_user}:${local.ssh_key_content}"
    serial-port-enable = true
    user-data          = data.cloudinit_config.system_setup.rendered
  }

  service_account {
    email  = var.sa_email
    scopes = var.sa_scopes
  }

  tags = var.vm_tags
}
