###===================================================================================###
#
#  File:  bind.main.tf
#  Created By: Karl Vietmeier
#
#  CoreInfra: tiny Ubuntu GCE + shared cloud-init BIND9 conditional forwarder.
#  Use when Cloud DNS private forwarding cannot be changed.
#
#  Files:
#    - bind.main.tf / bind.variables.tf / bind.provider.tf / bind.outputs.tf
#    - bind.auto.tfvars.example → copy to bind.auto.tfvars (gitignored)
#
#  Shared user-data (do not copy):
#    scripts/cloud-init/cloud-init-bind.yaml.tftpl
#
#  Day-2 knobs: vast_zones + vast_dns_ips (re-apply after cluster DNS VIP is known).
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

  # Shared multi-cloud template — path is four levels up from CoreInfra/vms/bind_forwarder
  cloudinit = templatefile("${path.module}/../../../../scripts/cloud-init/cloud-init-bind.yaml.tftpl", {
    vast_zones     = var.vast_zones
    vast_dns_ips   = var.vast_dns_ips
    query_cidrs    = local.query_cidrs
    cloud_resolver = var.cloud_resolver
  })
}

# Optional: allow clients to reach BIND on 53
resource "google_compute_firewall" "bind_dns" {
  count = var.enable_dns_firewall ? 1 : 0

  name        = "${var.vm_name}-allow-dns"
  network     = var.network_name
  description = "Allow UDP/TCP 53 to BIND forwarder tag from lab CIDRs"
  direction   = "INGRESS"
  priority    = 1000

  allow {
    protocol = "tcp"
    ports    = ["53"]
  }

  allow {
    protocol = "udp"
    ports    = ["53"]
  }

  source_ranges = local.query_cidrs
  target_tags   = var.vm_tags
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
    # Cloud-assigned private IP; no public IP by default (IAP)

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

  depends_on = [google_compute_firewall.bind_dns]
}
