###===================================================================================###
#
#  File:        multi.main.tf
#  Created By:  Karl Vietmeier
#
#  Description:
#    Provisions N Google Cloud VMs (e.g. client01, client02, …) with matching
#    per-VM SSH users (labuser01, labuser02, …).
#    Default: private-only NIC, cloud-assigned internal IP (same pattern as CoreInfra devops).
#    Optional: static private IPs via assign_static_ip + ip_start_offset.
#
###===================================================================================###

data "cloudinit_config" "system_setup" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content      = local.cloudinit_config
    filename     = "conf.yaml"
  }
}

resource "google_compute_instance" "vm_instance" {
  for_each     = local.vms
  name         = each.key
  zone         = var.zone
  machine_type = var.machine_type
  labels       = var.labels
  tags         = var.vm_tags

  boot_disk {
    initialize_params {
      image = var.os_image
      size  = var.bootdisk_size
    }
  }

  service_account {
    email  = var.service_account.email
    scopes = var.service_account.scopes
  }

  network_interface {
    subnetwork = var.subnet_name
    network_ip = var.assign_static_ip ? cidrhost(
      data.google_compute_subnetwork.my_subnet.ip_cidr_range,
      var.ip_start_offset + index(keys(local.vms), each.key)
    ) : null
    # No access_config — no public IP (IAP / bastion)
  }

  metadata = {
    # Ubuntu ships cloud-init; Rocky/RHEL may need install+reboot
    startup-script = <<-EOT
    #!/bin/bash
    command -v cloud-init &>/dev/null && exit 0
    sleep 10
    if command -v apt-get &>/dev/null; then
      apt-get update -y && apt-get install -y cloud-init && reboot
    elif command -v dnf &>/dev/null; then
      dnf install -y cloud-init && reboot
    fi
    EOT

    # Per-VM user: client01 → labuser01, etc.
    ssh-keys           = "${each.value.ssh_user}:${local.ssh_key_content}"
    serial-port-enable = true
    user-data          = data.cloudinit_config.system_setup.rendered
  }
}

output "vm_names" {
  value       = keys(local.vms)
  description = "Names of the client VMs"
}

output "vm_users" {
  value       = { for name, spec in local.vms : name => spec.ssh_user }
  description = "Map of VM name → SSH username"
}

output "vm_private_ips" {
  value       = { for name, vm in google_compute_instance.vm_instance : name => vm.network_interface[0].network_ip }
  description = "Map of VM name → cloud-assigned (or static) private IP"
}

output "ssh_commands" {
  value = {
    for name, vm in google_compute_instance.vm_instance :
    name => format(
      "gcloud compute ssh %s@%s --zone=%s --tunnel-through-iap",
      local.vms[name].ssh_user,
      name,
      var.zone
    )
  }
  description = "IAP SSH commands per VM"
}
