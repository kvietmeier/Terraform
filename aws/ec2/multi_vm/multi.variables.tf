###===================================================================================###
#
#  File:  multi.variables.tf
#  Created By: Karl Vietmeier
#
#  Identical client pool — mirrors gcp/VMs/multi_vm and azure/VMs/multi_vm.
#  Names: vm_name_prefix + vm_names list, or numbered vm_base_name fallback.
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
  description = "OS user for SSH / Ansible (strata after universal cloud-init)"
  type        = string
  default     = "strata"
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

###--- Identical VM pool

variable "vm_count" {
  description = "Number of identical client VMs when vm_names is empty"
  type        = number
  default     = 3
}

variable "vm_name_prefix" {
  description = "Prefix applied to every VM name (e.g. kv- → kv-copper, kv-linux01)"
  type        = string
  default     = "kv-"
}

variable "vm_base_name" {
  description = "Base name for numbered mode: {prefix}{base}01, 02, …"
  type        = string
  default     = "linux"
}

variable "vm_names" {
  description = "Optional short names (e.g. copper, lead). Non-empty → fleet size = length; names = prefix + each entry"
  type        = list(string)
  default     = []
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

  # Mode B (list) preferred for demos; Mode A (numbered) when vm_names is empty
  vm_names = length(var.vm_names) > 0 ? [
    for n in var.vm_names : "${var.vm_name_prefix}${n}"
    ] : [
    for i in range(var.vm_count) : format("%s%s%02d", var.vm_name_prefix, var.vm_base_name, i + 1)
  ]
}
