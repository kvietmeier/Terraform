###===================================================================================###
#
#  File:  variables.tf
#  Created By: Karl Vietmeier
#
#  Variable definitions with some defaults
#
###===================================================================================###

# Get subnet CIDR
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

# VM Config
variable "vms" {
  description = "Map of VM configurations"
  type = map(object({
    machine_type  = string
    bootdisk_size = string
    os_image      = string
    ip_octet      = string
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

# Subnet name
variable "subnet_name" {
  description = "The name of the subnetwork"
  type        = string
  default     = "default"
}


###=================          Locals                ==================###
locals {
  # Read the SSH public keys file
  ssh_key_content = file(var.ssh_key_file)
  
  # cloud-init file
  cloudinit_config  = file(var.cloudinit_configfile)
}
