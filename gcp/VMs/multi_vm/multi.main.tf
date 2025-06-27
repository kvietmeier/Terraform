###===================================================================================###
#
#  File:        multi.main.tf
#  Created By:  Karl Vietmeier
#
#  Description: 
#    This Terraform configuration dynamically provisions multiple Google Cloud VMs 
#    with consistent naming (e.g., linux01, linux02, ...) and assigns each instance 
#    a static private IP address within a subnet using a configurable starting offset. 
#    The static IPs are calculated using cidrhost() and the VM index.
#
#  Inputs:
#    - vm_count:         Number of VMs to create
#    - vm_base_name:     Base name used for VM instances
#    - ip_start_offset:  Starting IP host offset within the subnet
#
#  Behavior:
#    - VM names are auto-generated using the base name and a 2-digit suffix
#    - Static IPs are assigned incrementally from the starting offset
#    - Cloud-init is used for OS configuration at startup
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
  for_each     = toset(local.vm_names)
  name         = each.value
  
  zone         = var.zone             # Use the zone variable
  machine_type = var.machine_type     # Use the machine_type variable
  
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
    subnetwork = var.subnet_name
    network_ip = cidrhost(
      data.google_compute_subnetwork.my_subnet.ip_cidr_range,
      var.ip_start_offset + index (local.vm_names, each.value)) 
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
### END VM Resource


output "vm_private_ips" {
  value = [for vm in google_compute_instance.vm_instance : vm.network_interface[0].network_ip]
  description = "List of private IP addresses of the VMs"
}
