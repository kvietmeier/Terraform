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

# Reserve a specific static external (public) IP address
resource "google_compute_address" "my_public_ip" {
  name         = var.public_ip_name
  address_type = "EXTERNAL"
  region       = var.region
}


#
###=================   Create VM instance with public IP   ===================###
#
resource "google_compute_instance" "vm_instance" {
  zone         = var.zone             # Use the zone variable
  name         = var.vm_name          # Use the vm_name variable
  machine_type = var.machine_type     # Use the machine_type variable

  boot_disk {
    initialize_params {
      image    = var.os_image         # Replace with your preferred image
      size     = var.bootdisk_size
    }
  }

  # Configure the network interface with the specified private and public IPs
  network_interface {
    subnetwork    = var.subnet_name
    #network_ip    = google_compute_address.my_private_ip.address  # Specified static private IP
    
    # Enables a public IP address
    access_config {
      # Specified static public IP
      nat_ip = google_compute_address.my_public_ip.address
    }
  }

  metadata = {
    # Windows post install config
    #enable-windows-automatic-updates = "true"
    windows-startup-script-ps1       = file("../../scripts/windows-startup-config.ps1")
    admin-password                   = "Chalc0pyr1te123$"  
  }

  tags = var.vm_tags
  
  service_account {
    # Google recommends custom service accounts with `cloud-platform` scope with
    # specific permissions granted via IAM Roles.
    email  = var.sa_email
    scopes = var.sa_scopes
  }
}
#
###===================       End VM Resource Block       ===================###
#


###===================   Outputs  ===================###

# Output the public IP address
output "public_ip" {
  value       = google_compute_address.my_public_ip.address
  description = "Reserved public IP address for the VM"
}

# Output the private IP address
output "private_ip" {
  value = google_compute_instance.vm_instance.network_interface[0].network_ip
  description = "The private IP address of the VM instance."
}