###===================================================================================###
# File:         variables.tf
# Description:  Variable definitions for multi.main.tf using machine images
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

variable "service_account" {
  description = "Service account configuration"
  type = object({
    email  = string
    scopes = list(string)
  })
}

# VM Config (machine-image based)
variable "vms" {
  description = "Map of VM configurations"
  type = map(object({
    machine_type  = string
    bootdisk_size = number
    machine_image = string
  }))
}

###--- VM Metadata

variable "ssh_user" {
  description = "User to SSH in as"
  type        = string
}

variable "ssh_key_file" {
  description = "Path to the SSH public key file"
  type        = string
}

###--- Network

variable "vpc_name" {
  description = "The name of the VPC network"
  type        = string
  default     = "default"
}

variable "subnet_name" {
  description = "The name of the subnetwork"
  type        = string
  default     = "default"
}

###================= Locals =================###

locals {
  # Read the SSH public key file
  ssh_key_content = file(var.ssh_key_file)
}
