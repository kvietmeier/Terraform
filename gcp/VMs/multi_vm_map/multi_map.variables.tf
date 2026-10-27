###===================================================================================###
#
#  File:  multi_map.variables.tf
#  Created By: Karl Vietmeier
#
#  Unique VMs via map; keys are short names. Name = vm_name_prefix + key.
#
###===================================================================================###

data "google_compute_subnetwork" "my_subnet" {
  name   = var.subnet_name
  region = var.region
}

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region to deploy resources"
  type        = string
}

variable "zone" {
  description = "The GCP zone to deploy the VM"
  type        = string
}

variable "service_account" {
  description = "Service account configuration"
  type = object({
    email  = string
    scopes = list(string)
  })
}

variable "vm_name_prefix" {
  description = "Prefix applied to each map key for the instance name"
  type        = string
  default     = "kv-"
}

variable "vms" {
  description = "Map of VM configurations; key = short name (copper, lead, …)"
  type = map(object({
    machine_type  = string
    bootdisk_size = string
    os_image      = string
    ip_octet      = string
  }))
}

variable "ssh_user" {
  description = "Shared SSH user (strata after universal cloud-init)"
  type        = string
  default     = "strata"
}

variable "ssh_key_file" {
  description = "Path to the SSH public key file"
  type        = string
}

variable "cloudinit_configfile" {
  description = "Path to the cloud-init yaml"
  type        = string
}

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

locals {
  ssh_key_content  = file(var.ssh_key_file)
  cloudinit_config = file(var.cloudinit_configfile)

  vms = {
    for short, spec in var.vms : "${var.vm_name_prefix}${short}" => spec
  }
}
