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

# Service Account
variable "sa_email" {
  description = "Service Account email"
  type        = string
}

variable "sa_scopes" {
  description = "Scope for Service Account"
  type        = list(string)
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
  default     = "windows-server-2022-dc-v20241115"
}

variable "bootdisk_size" {
  description = "Size of boot disk in GB"
  type        = string
  default     = "150"
}

###--- VM Metadata
variable "windows-startup-script" {
  description = "Windows config script"
  type        = string
}

variable vm_tags {
  description = "Tags"
  type        = list(string)
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

variable "public_ip_name" {
  description = "Name for Private IP"
  type        = string
  default     = "karlv-pubip"
}

variable "private_ip_name" {
  description = "Name for Public IP"
  type        = string
  default     = "karlv-pubip"
}

variable "private_ip" {
  description = "Static Private IP"
  type        = string
  default     = "karlv-pubip"
}

/*
# Subnet CIDR range
variable "subnet_cidr" {
  description = "CIDR range for the subnet"
  type        = string
  default     = "10.0.0.0/24"
}
*/

###=================          Locals                ==================###


# cloud-init file
locals {
  windows-startup-script = file(var.windows-startup-script)
}


