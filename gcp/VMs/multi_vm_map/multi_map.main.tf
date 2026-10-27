###===================================================================================###
#
#  File:         multi_map.main.tf
#  Created By:   Karl Vietmeier
#
#  Description:  Unique GCE clients from a map. Keys are short names; instance
#                name = vm_name_prefix + key (e.g. kv-copper). Shared ssh_user.
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
    subnetwork = var.subnet_name
    network_ip = cidrhost(data.google_compute_subnetwork.my_subnet.ip_cidr_range, each.value.ip_octet)
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
}

output "vm_names" {
  value       = keys(google_compute_instance.vm_instance)
  description = "Full VM names (prefix + short key)"
}

output "vm_private_ips" {
  value       = { for name, vm in google_compute_instance.vm_instance : name => vm.network_interface[0].network_ip }
  description = "Map of VM name → private IP (for Ansible inventory)"
}

output "ssh_commands" {
  value = {
    for name, vm in google_compute_instance.vm_instance :
    name => format(
      "gcloud compute ssh %s@%s --zone=%s --project=%s --tunnel-through-iap",
      var.ssh_user,
      name,
      var.zone,
      var.project_id
    )
  }
  description = "IAP SSH commands per VM"
}
