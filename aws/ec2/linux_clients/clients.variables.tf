###===================================================================================###
#
#  File:  clients.variables.tf
#  Created By: Karl Vietmeier
#
#  Variable definitions — all values come from tfvars
#  Pattern mirrors gcp/VMs/multi_vm (identical client pool via count + base name)
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

###--- AMI lookup

variable "os_amis" {
  description = "AMI search criteria keyed by os_type (e.g. ubuntu, rocky)"
  type = map(object({
    owners      = list(string)
    name_filter = string
  }))
}

###--- Identical VM pool (like gcp/VMs/multi_vm)

variable "num_vm" {
  description = "Number of identical client VMs to create"
  type        = number
}

variable "vm_base_name" {
  description = "Base name for instances; names are {vm_base_name}01, {vm_base_name}02, ..."
  type        = string
  default     = "voc-client"
}

variable "machine_type" {
  description = "EC2 instance type for every VM in the pool"
  type        = string
}

variable "bootdisk_size" {
  description = "Root volume size (GiB) for every VM in the pool"
  type        = number
}

variable "os_type" {
  description = "OS key into var.os_amis (must match a key there)"
  type        = string
}

###=================          Locals                ==================###
locals {
  cloudinit_config = file(var.cloudinit_configfile)

  # voc-client01, voc-client02, ... (same naming as prior map keys → state-safe)
  vm_names = [for i in range(var.num_vm) : format("%s%02d", var.vm_base_name, i + 1)]
}
