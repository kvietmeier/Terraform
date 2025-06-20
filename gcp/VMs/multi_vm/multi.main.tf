###===================================================================================###
#
#  File:  multi.main.tf
#  Created By: Karl Vietmeier
#
#  Terraform Module Code
#  Purpose:  Create multiple identical VMs from a simple list
#  vm_names             = ["linux01", "linux02", "linux03"]
# 
###===================================================================================###


###===================================================================================###
###                  Start creating infrastructure resources                          ###

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
    email  = var.service_account.email
    scopes = var.service_account.scopes
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
