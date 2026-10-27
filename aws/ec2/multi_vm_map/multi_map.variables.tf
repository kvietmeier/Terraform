###===================================================================================###
#
#  File:  clients.variables.tf
#  Created By: Karl Vietmeier
#
#  Variable definitions — all values come from tfvars
#  Pattern mirrors gcp/VMs/multi_vm_map (unique VMs via map; key = Name tag)
#
###===================================================================================###

###--- Provider / account

variable "region" {
  description = "AWS region to deploy resources (also honor AWS_REGION in the shell)"
  type        = string
}

###--- Network

variable "vpc_id" {
  description = "VPC ID (informational / for future use)"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID to launch EC2 instances in"
  type        = string
}

variable "security_group_ids" {
  description = "Security group IDs to attach to EC2 instances"
  type        = list(string)
}

###--- Instance identity / access

variable "ssh_key_name" {
  description = "Name of an existing AWS EC2 Key Pair for SSH access"
  type        = string
}

variable "ssh_user" {
  description = "OS user for SSH / Ansible (labuser after universal cloud-init)"
  type        = string
  default     = "labuser"
}

variable "ssh_private_key_path" {
  description = "Local private key path shown in formatted ssh -i commands"
  type        = string
}

variable "cloudinit_configfile" {
  description = "Path to the cloud-init yaml"
  type        = string
}

variable "common_tags" {
  description = "Tags applied to all instances (Name is set per-VM)"
  type        = map(string)
  default     = {}
}

###--- AMI lookups (keyed by os_type used in var.vms)

variable "os_amis" {
  description = "AMI search criteria keyed by os_type (e.g. ubuntu, rocky)"
  type = map(object({
    owners      = list(string)
    name_filter = string
  }))
}

###--- Unique VMs (like gcp/VMs/multi_vm_map)

variable "vms" {
  description = "Map of VM configurations; key = instance Name tag"
  type = map(object({
    machine_type  = string
    bootdisk_size = number
    os_type       = string # must match a key in var.os_amis
  }))
}

###=================          Locals                ==================###
locals {
  cloudinit_config = file(var.cloudinit_configfile)

  # Only look up AMIs for os_types actually used by var.vms
  used_os_amis = {
    for os_type, ami in var.os_amis : os_type => ami
    if contains([for vm in var.vms : vm.os_type], os_type)
  }
}
