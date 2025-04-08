###===================================================================================###
#
#  File:  Template.tf
#  Created By: Karl Vietmeier
#
#  Terraform Module Code
#  Purpose:  Create multiple identical VMs from a simple list
#  vm_names             = ["linux01", "linux02", "linux03"]
# 
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

/*
# Reserve a specific static external (public) IP address
resource "google_compute_address" "my_public_ip" {
  name         = "karlv-public-ip"
  address_type = "EXTERNAL"
  region       = var.region
}
*/

# Google Cloud VM instance with public IP
resource "google_compute_instance" "vm_instance" {
  zone         = var.zone             # Use the zone variable
  machine_type = var.machine_type     # Use the machine_type variable
  
  for_each     = toset(var.vm_names)
  name         = each.value

  boot_disk {
    initialize_params {
      image    = var.os_image  # Replace with your preferred image
      size     = var.bootdisk_size
    }
  }

  service_account {
    # Needed for the monitoring agent
    email  = "913067105288-compute@developer.gserviceaccount.com"   # Replace with your service account email
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/bigquery"
    ]
  }
  
  # Configure the network interface with the specified private and public IPs
  network_interface {
    subnetwork    = var.subnet_name
    #network_ip    = google_compute_address.my_private_ip.address  # Specified static private IP

    #access_config {                         # Enables a public IP address
    #  nat_ip = google_compute_address.my_public_ip.address       # Specified static public IP
    #}
  }

  metadata = {
    # Install cloud-init if not available yet
    startup-script = <<-CLOUDINIT
    #!/bin/bash
    sleep 30
    command -v cloud-init &>/dev/null || (dnf install -y cloud-init && reboot)
    CLOUDINIT
    
    ssh-keys           = "${var.ssh_user}:${local.ssh_key_content}"
    serial-port-enable = true # Enable serial port access for debugging
    user-data          = "${data.cloudinit_config.system_setup.rendered}"

  }

  #tags = ["kv-linux", "kv-infra"]
}

output "vm_private_ips" {
  value = [for vm in google_compute_instance.vm_instance : vm.network_interface[0].network_ip]
  description = "List of private IP addresses of the VMs"
}


/*
# Output the IP addresses
output "instance_public_ip" {
  value = google_compute_address.my_public_ip.address
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
