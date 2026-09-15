###===================================================================================###
#  Module: vms/windows
#  Adapted from gcp/CoreInfra/vms/w22server
###===================================================================================###

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
    enable-windows-automatic-updates = "true"
    sysprep-specialize-script-ps1    = file(var.windows_sysprep_script)
  }

  tags = var.vm_tags

  service_account {
    email  = var.sa_email
    scopes = var.sa_scopes
  }
}
