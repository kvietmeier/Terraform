###===================================================================================###
#
#  File:  vmmap.main.tf
#  Created By: Karl Vietmeier
#
#  Create a group of unique VMs using a map variable
#  
#  Need:  A way to assign a different cloud-init to each VM in case they are different OS
#
###===================================================================================###


###===================================================================================###
#     Start creating infrastructure resources
###===================================================================================###

###--- Setup cloud-init
data "cloudinit_config" "dnf_system_setup" {
  gzip = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content      = "${local.cloudinit_config}"
    filename     = "conf.yaml"
  }
}


###====  Create the VMs
resource "google_compute_instance" "vm" {
  for_each = var.vm_instances

  name         = "${var.base_name}-${each.key}"
  machine_type = each.value.machine_type
  zone         = each.value.zone

  boot_disk {
    initialize_params {
      image = each.value.os_image
      size  = each.value.disk_size_gb
    }
  }

  network_interface {
    network    = each.value.network
    subnetwork = each.value.subnetwork

    access_config {
      # Ephemeral external IP
    }
  }
  
  metadata = {
    # Install cloud-init if not available yet
    startup-script = <<-EOT
      #!/usr/bin/bash
      command -v cloud-init &>/dev/null || (dnf install -y cloud-init && reboot)
    EOT

    ssh-keys           = "${var.ssh_user}:${local.ssh_key_content}"
    serial-port-enable = true 
    user-data          = "${data.cloudinit_config.dnf_system_setup.rendered}"
  }

}


/*
# Reserve a specific static external (public) IP address
resource "google_compute_address" "my_public_ip" {
  name         = "karlv-public-ip"
  address_type = "EXTERNAL"
  region       = var.region
}
*/

###=============================== Outputs ====================================###
output "vm_private_ips" {
  value = { 
    for vm, instance in google_compute_instance.vm :
    instance.name => instance.network_interface[0].network_ip
  }

  description = "VM names and their corresponding private IP addresses"
}

output "private_dns" {
  value = join("\n", [ 
    for instance in google_compute_instance.vm :
    "${instance.name}.${var.gcp_priv_dns}"
  ])

  description = "List of VM names and their private IPs as a single string"
}
