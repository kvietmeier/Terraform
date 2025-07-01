###===================================================================================###
#
#  File:  variables.tf
#  Created By: Karl Vietmeier
#
#  Variable definitions with some defaults
#
###===================================================================================###

data "google_compute_subnetwork" "my_subnet" {
  name    = var.subnet_name
  region  = var.region
}

# Project ID
variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

# Region
variable "region" {
  description = "The GCP region to deploy resources"
  type        = string
}

# Zone
variable "zone" {
  description = "The GCP zone to deploy the VM"
  type        = string
}


###--- VM Info

variable "service_account" {
  description = "Service account configuration"
  type = object({
    email  = string
    scopes = list(string)
  })
}

# VM instance count
variable "vm_count" {
  description = "Number of VMs to create"
  type    = string
}

# Base name for VMs
variable "vm_base_name" {
  type        = string
  description = "Base name for VM instances"
  default     = "linux"
}

# Machine type for the VM
variable "machine_type" {
  description = "The machine type for the VM"
  type        = string
  default     = "e2-medium"
}

variable "os_image" {
  description = "OS Image to use"
  type        = string
}

variable "bootdisk_size" {
  description = "Size of boot disk in GB"
  type        = string
  default     = "150"
}

###--- VM Metadata
# SSH 
variable "ssh_user" {
  description = "User to SSH in as"
  type        = string
}

variable "ssh_key_file" {
  description = "Path to the SSH public key file"
  type        = string
}

variable "cloudinit_configfile" {
  description = "Path to the cloud-init yaml"
  type        = string
}


###--- Network

# Network name
variable "vpc_name" {
  description = "The name of the VPC network"
  type        = string
  default     = "default"
}

# Subnet name
variable "subnet_name" {
  description = "The name of the subnetwork"
  type        = string
  default     = "default"
}

variable "ip_start_offset" {
  type        = number
  description = "Offset to start IP assignments within the subnet"
  default     = 20
}

###=================          Locals                ==================###
locals {
  # Read the SSH public keys file
  ssh_key_content = file(var.ssh_key_file)
  
  # cloud-init file
  cloudinit_config  = file(var.cloudinit_configfile)

  # Create the list of vm names
  vm_names = [for i in range(var.vm_count) : format("%s%02d", var.vm_base_name, i + 1)]

}
