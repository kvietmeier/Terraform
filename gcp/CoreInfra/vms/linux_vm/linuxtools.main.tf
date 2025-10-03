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
data "cloudinit_config" "conf" {
  gzip = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content = file("../../secrets/cloud-init-dnfbased.default.yaml")
    filename = "conf.yaml"
  }
}

# Reserve a specific static external (public) IP address
resource "google_compute_address" "my_public_ip" {
  name         = "karlv-public-ip"
  address_type = "EXTERNAL"
  region       = var.region
}

resource "google_compute_address" "my_private_ip" {
  name         = "karlv-private-ip"
  address_type = "INTERNAL"
  subnetwork   = var.subnet_name
  region       = var.region
  address      = "10.111.1.4" # Replace with your desired static private IP
}

# Google Cloud VM instance with public IP
resource "google_compute_instance" "vm_instance" {
  zone         = var.zone             # Use the zone variable
  name         = var.vm_name          # Use the vm_name variable
  machine_type = var.machine_type     # Use the machine_type variable

  boot_disk {
    initialize_params {
      image    = var.os_image  # Replace with your preferred image
      size     = var.bootdisk_size
    }
  }

  # Configure the network interface with the specified private and public IPs
  network_interface {
    subnetwork    = var.subnet_name
    network_ip    = google_compute_address.my_private_ip.address  # Specified static private IP

    access_config {                         # Enables a public IP address
      nat_ip = google_compute_address.my_public_ip.address       # Specified static public IP
    }
  }

  metadata = {
    #user-data          = "${data.cloudinit_config.conf.rendered}"
    #ssh-keys           = "${var.ssh_user}:${local.ssh_key_content}"
    ssh-keys           = "${file(var.ssh_key_file)}"
    serial-port-enable = true # Enable serial port access for debugging
  }

  tags = ["kv-linux", "kv-infra"]
}


# Output the IP addresses
output "instance_public_ip" {
  value = google_compute_address.my_public_ip.address
}

output "instance_private_ip" {
  value = google_compute_address.my_private_ip.address
}
