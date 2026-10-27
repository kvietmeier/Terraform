###===================================================================================###
#
#  File:        multi.main.tf
#  Created By:  Karl Vietmeier
#
#  Description:
#    Provisions N Google Cloud VMs (kv-linux01… or kv-copper…) with a single
#    shared SSH user (strata). Private-only NIC by default (IAP / bastion).
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

    ssh-keys           = "${each.value.ssh_user}:${local.ssh_key_content}"
    serial-port-enable = true
    user-data          = data.cloudinit_config.system_setup.rendered
  }
}

###===================================================================================###
###  Outputs
###===================================================================================###

output "vm_names" {
  value       = keys(local.vms)
  description = "Names of the client VMs"
}

output "vm_users" {
  value       = { for name, spec in local.vms : name => spec.ssh_user }
  description = "Map of VM name → SSH username (shared strata)"
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
      local.vms[name].ssh_user,
      name,
      var.zone,
      var.project_id
    )
  }
  description = "IAP SSH commands per VM"
}

output "stop_commands" {
  value = {
    for name, vm in google_compute_instance.vm_instance :
    name => format(
      "gcloud compute instances stop %s --zone=%s --project=%s",
      name,
      var.zone,
      var.project_id
    )
  }
  description = "Per-VM stop commands"
}

output "start_commands" {
  value = {
    for name, vm in google_compute_instance.vm_instance :
    name => format(
      "gcloud compute instances start %s --zone=%s --project=%s",
      name,
      var.zone,
      var.project_id
    )
  }
  description = "Per-VM start commands"
}

output "power_cheatsheet" {
  value = join("\n", flatten([
    ["# stop"],
    [for name in sort(keys(local.vms)) :
      format("gcloud compute instances stop %s --zone=%s --project=%s", name, var.zone, var.project_id)
    ],
    [""],
    ["# start"],
    [for name in sort(keys(local.vms)) :
      format("gcloud compute instances start %s --zone=%s --project=%s", name, var.zone, var.project_id)
    ],
  ]))
  description = "Newline-separated per-VM stop then start commands"
}
