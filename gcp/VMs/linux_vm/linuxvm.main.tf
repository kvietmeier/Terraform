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


# Reserve a specific static external (public) IP address
resource "google_compute_address" "my_public_ip" {
  name         = var.public_ip_name
  address_type = "EXTERNAL"
  region       = var.region
}

resource "google_compute_address" "my_private_ip" {
  name         = var.private_ip_name
  address_type = "INTERNAL"
  subnetwork   = var.subnet_name
  region       = var.region
  address      = var.private_ip
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
    network_ip    = google_compute_address.my_private_ip.address  # Specified static private IP

    access_config {                                               # Enables a public IP address
      nat_ip = google_compute_address.my_public_ip.address        # Specified static public IP
    }
  }
  
  can_ip_forward = true

  metadata = {
    # Install cloud-init if not available yet
    startup-script = <<-EOT
      #!/bin/bash
      command -v cloud-init &>/dev/null || (dnf install -y cloud-init && reboot)
    EOT
    
    ssh-keys           = "${var.ssh_user}:${local.ssh_key_content}"
    serial-port-enable = true 
    user-data          = "${data.cloudinit_config.system_setup.rendered}"
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
