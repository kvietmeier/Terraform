###===================================================================================###
#
#  File:  variables.tf
#  Created By: Karl Vietmeier
#
#  Variable definitions with defaults
#
###===================================================================================###
# Identity
variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "compartment_id" {
  description = "OCI Compartment OCID"
}

# Region/AD
variable "region" {}
variable "availability_domain" {
  description = "e.g., Uocm:US-ASHBURN-AD-1"
}

# VM Info
variable "vm_count" { type = number }
variable "vm_base_name" { default = "linux" }
variable "shape" { 
  description = "OCI Shape (e.g., VM.Standard.E4.Flex)"
  default     = "VM.Standard.E4.Flex" 
}

# Flex Shape Config (if using E3/E4/E5)
variable "shape_config" {
  type = object({
    ocpus         = number
    memory_in_gbs = number
  })
  default = {
    ocpus         = 8
    memory_in_gbs = 64
  }
}

variable "os_image_id" { description = "OCID of the image" }
variable "bootdisk_size" { default = 150 }

# Networking
variable "subnet_id" { description = "OCID of the OCI Subnet" }
variable "ip_start_offset" { default = 20 }

# Metadata
variable "ssh_user" {}
variable "ssh_key_file" {}
variable "cloudinit_configfile" {}

data "oci_core_subnet" "selected_subnet" {
  subnet_id = var.subnet_id
}

locals {
  ssh_key_content  = file(var.ssh_key_file)
  cloudinit_config = file(var.cloudinit_configfile)
  vm_names         = [for i in range(var.vm_count) : format("%s%02d", var.vm_base_name, i + 1)]
}