###===================================================================================###
#
#  File:  Template.tf
#  Created By: Karl Vietmeier
#
#  Terraform Module Code
#  Purpose:  Create a VM
#            With basic settings
# 
#  Files in Module:
#    main.tf
#    variables.tf
#    variables.tfvars
#
#  Usage:
#  terraform apply --auto-approve
#  terraform destroy --auto-approve
###===================================================================================###

/* 

Put Usage Documentation here

*/


###===================================================================================###
#     Start creating infrastructure resources
###===================================================================================###

# Setup cloud-init
data "cloudinit_config" "system_setup" {
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
      #!/bin/bash
      command -v cloud-init &>/dev/null || (dnf install -y cloud-init && reboot)
    EOT
    
    ssh-keys           = "${var.ssh_user}:${local.ssh_key_content}"
    serial-port-enable = true # Enable serial port access for debugging
    user-data          = "${data.cloudinit_config.system_setup.rendered}"

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


/*
# Output the IP addresses
output "instance_public_ip" {
  value = google_compute_address.my_public_ip.address
}

output "vm_private_ips" {
  value = [for vm in google_compute_instance.vm_instance : vm.network_interface[0].network_ip]
  description = "List of private IP addresses of the VMs"
}

output "instance_private_ip" {
  #value = google_compute_address.my_private_ip.address
  value = google_compute_address.vm_instance.network_interface[0].network_ip
}
*/


####--- 
# Network resource (optional: create a new VPC)
/*
resource "google_compute_network" "vpc_network" {
  name                    = var.vpc_name     # Use the network_name variable
  auto_create_subnetworks = "false"
}

# Subnetwork
resource "google_compute_subnetwork" "infra_subnet" {
  name          = var.subnet_name     # Use the subnet_name variable
  region        = var.region          # Use the region variable
  ip_cidr_range = var.subnet_cidr     # Use the subnet_cidr variable
  network       = "default"           # Create in default VPC
}

# Firewall rule to allow only specific IP addresses
resource "google_compute_firewall" "allow_specific_ip" {
  name    = var.fw_rule_name
  network = google_compute_network.vpc_network.id

  allow {
    protocol = var.net_protocol
    ports    = var.destination_ports 
  }

  source_ranges = var.whitelist_ips
}


# Reserve a static public IP for the VM
resource "google_compute_address" "vm_public_ip" {
  name   = "vm-public-ip"
  region = var.region                # Use the region variable
}
*/
