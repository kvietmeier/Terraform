###===================================================================================###
#
#  File:  bind.main.tf
#  Created By: Karl Vietmeier
#
#  Tiny Ubuntu GCE + shared cloud-init BIND9 conditional forwarder.
#  Use when Cloud DNS private forwarding cannot be changed.
#  Day-2 knobs: vast_zones + vast_dns_ips.
#
###===================================================================================###

locals {
  query_cidrs = distinct(concat([var.vpc_cidr], var.additional_query_cidrs))

  labels = merge(
    var.labels,
    {
      vast-client = "true"
      role        = "bind-vast-forwarder"
    }
  )

  ssh_key_content = file(var.ssh_key_file)

  # Shared multi-cloud template — edit scripts/cloud-init/, not a per-cloud copy
  cloudinit = templatefile("${path.module}/../../../scripts/cloud-init/cloud-init-bind.yaml.tftpl", {
    vast_zones     = var.vast_zones
    vast_dns_ips   = var.vast_dns_ips
    query_cidrs    = local.query_cidrs
    cloud_resolver = var.cloud_resolver
  })
}

resource "google_compute_instance" "bind" {
  name         = var.vm_name
  zone         = var.zone
  machine_type = var.machine_type
  labels       = local.labels
  tags         = var.vm_tags

  boot_disk {
    initialize_params {
      image = var.os_image
      size  = var.bootdisk_size
    }
  }

  network_interface {
    subnetwork = var.subnet_name

    dynamic "access_config" {
      for_each = var.assign_public_ip ? [1] : []
      content {}
    }
  }

  metadata = {
    ssh-keys           = "${var.ssh_user}:${local.ssh_key_content}"
    serial-port-enable = true
    user-data          = local.cloudinit
  }

  service_account {
    email  = var.sa_email
    scopes = var.sa_scopes
  }
}
