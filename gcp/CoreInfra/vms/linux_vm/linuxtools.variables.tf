###===================================================================================###
#
#  File:  variables.tf
#  Created By: Karl Vietmeier
#
#  Variable definitions with defaults
#
###===================================================================================###

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
# Machine type for the VM
variable "machine_type" {
  description = "The machine type for the VM"
  type        = string
  default     = "e2-medium"
}

# VM instance name
variable "vm_name" {
  description = "Name of the VM instance"
  type        = string
  default     = "my-vm"
}

variable "os_image" {
  description = "OS Image to use"
  type        = string
  default     = "centos-stream-9-v20241009"
}

variable "bootdisk_size" {
  description = "Size of boot disk in GB"
  type        = string
  default     = "40"
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


###--- Network

# Network name
variable "vpc_name" {
  description = "The name of the VPC network"
  type        = string
  default     = "custom-network"
}

# Subnet name
variable "subnet_name" {
  description = "The name of the subnetwork"
  type        = string
  default     = "custom-subnet"
}

# Subnet CIDR range
variable "subnet_cidr" {
  description = "CIDR range for the subnet"
  type        = string
  default     = "10.0.0.0/24"
}

###=================          Locals                ==================###

# Read the SSH public key
#locals {
#  ssh_key_content = file(var.ssh_key_file)
#}

