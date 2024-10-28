###===================================================================================###
#
#  File:  Template.tf
#  Created By: Karl Vietmeier
#
#  Terraform Module Code
#  Purpose:  Create a VM
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
data "cloudinit_config" "conf" {
  gzip = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content = file("../../secrets/cloud-init-dnfbased.default.yaml")
    filename = "conf.yaml"
  }
}


# Network resource (optional: create a new VPC)
resource "google_compute_network" "vpc_network" {
  name                    = var.network_name     # Use the network_name variable
  auto_create_subnetworks = "false"
}

# Subnetwork
resource "google_compute_subnetwork" "subnetwork" {
  region        = var.region          # Use the region variable
  name          = var.subnet_name     # Use the subnet_name variable
  ip_cidr_range = var.subnet_cidr     # Use the subnet_cidr variable
  network       = google_compute_network.vpc_network.id
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

# Google Cloud VM instance with public IP
resource "google_compute_instance" "vm_instance" {
  zone         = var.zone             # Use the zone variable
  name         = var.vm_name          # Use the vm_name variable
  machine_type = var.machine_type     # Use the machine_type variable

  boot_disk {
    initialize_params {
      image = var.os_image  # Replace with your preferred image
      size  = var.bootdisk_size
    }
  }

  network_interface {
    network     = google_compute_network.vpc_network.id
    subnetwork  = google_compute_subnetwork.subnetwork.id
    
    access_config {    # This gives the VM a public IP
      nat_ip = google_compute_address.vm_public_ip.address
    }
  }

  metadata = {
    user-data          = "${data.cloudinit_config.conf.rendered}"
    ssh-keys           = "${var.ssh_user}:${local.ssh_key_content}"
    serial-port-enable = true # Enable serial port access for debugging
  }

  tags = ["kv-linux", "kv-infra"]
}

# Reserve a static public IP for the VM
resource "google_compute_address" "vm_public_ip" {
  name   = "vm-public-ip"
  region = var.region                # Use the region variable
}
