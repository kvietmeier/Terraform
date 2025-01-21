###===================================================================================###
#
#  File:  variables.tf
#  Created By: Karl Vietmeier
#
#  Variable definitions with defaults
#
#  Added code to create VMs from a map
#
###===================================================================================###

###=================          Locals                ==================###
locals {
  # Read the SSH public key
  ssh_key_content = file(var.ssh_key_file)
  
  # cloud-init file
  cloudinit_config = file(var.cloudinit_configfile)
}

###===================================================================###


### Basic Provider Info
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
# Base name for VMs
variable "base_name" {
  type        = string
  description = "Base name for all VM instances"
  default     = "base-vm"
}

# Define the map
variable "vm_instances" {
  type = map(object({
    machine_type = string
    zone         = string
    disk_size_gb = number
    os_image     = string
    network      = string
    subnetwork   = string
    #cloudinit    = string
  }))
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

variable "gcp_priv_dns" {
  description = "Private FQDN"
  type        = string
  default     = "c.clouddev-itdesk124.internal"
}

# Subnet name
variable "subnet_name" {
  description = "The name of the subnetwork"
  type        = string
  default     = "default"
}

variable "public_ip_name" {
  description = "name for a public IP"
  type        = string
  default     = "karlv-pubip"
}


###=================          unused                ==================###
/*
# Subnet CIDR range
variable "subnet_cidr" {
  description = "CIDR range for the subnet"
  type        = string
  default     = "10.0.0.0/24"
}
*/

###=================          Locals                ==================###


