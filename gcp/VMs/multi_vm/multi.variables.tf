###===================================================================================###
#
#  File:  multi.variables.tf
#  Created By: Karl Vietmeier
#
#  Identical client pool — mirrors aws/ec2/multi_vm and azure/VMs/multi_vm.
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
  description = "The GCP zone to deploy the VMs"
  type        = string
}

variable "service_account" {
  description = "Service account configuration"
  type = object({
    email  = string
    scopes = list(string)
  })
}

variable "vm_count" {
  description = "Number of VMs when vm_names is empty"
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
  description = "Optional short names (e.g. copper, lead). Non-empty → fleet size = length"
  type        = list(string)
  default     = []
}

variable "ssh_user" {
  description = "Shared SSH / Ansible user on every VM (strata after universal cloud-init)"
  type        = string
  default     = "strata"
}

variable "machine_type" {
  description = "The machine type for the VMs"
  type        = string
  default     = "e2-medium"
}

variable "os_image" {
  description = "OS image or family (e.g. ubuntu-os-cloud/ubuntu-2404-lts-amd64)"
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
}

variable "bootdisk_size" {
  description = "Size of boot disk in GB"
  type        = string
  default     = "50"
}

variable "ssh_key_file" {
  description = "Path to the SSH public key file (multi-key OK)"
  type        = string
}

variable "cloudinit_configfile" {
  description = "Path to the cloud-init yaml"
  type        = string
}

variable "vm_tags" {
  description = "Network tags for firewall targeting"
  type        = list(string)
  default     = []
}

variable "labels" {
  description = "GCE labels (e.g. used=solutions, owned_by=solutions)"
  type        = map(string)
  default     = {}
}

variable "vpc_name" {
  description = "The name of the VPC network (informational)"
  type        = string
  default     = "default"
}

variable "subnet_name" {
  description = "The name of the subnetwork"
  type        = string
  default     = "default"
}

variable "assign_static_ip" {
  description = "If true, assign static private IPs from ip_start_offset; if false, cloud-assign"
  type        = bool
  default     = false
}

variable "ip_start_offset" {
  type        = number
  description = "Host offset for static private IPs when assign_static_ip is true"
  default     = 20
}

locals {
  ssh_key_content  = file(var.ssh_key_file)
  cloudinit_config = file(var.cloudinit_configfile)

  vm_name_list = length(var.vm_names) > 0 ? [
    for n in var.vm_names : "${var.vm_name_prefix}${n}"
    ] : [
    for i in range(var.vm_count) : format("%s%s%02d", var.vm_name_prefix, var.vm_base_name, i + 1)
  ]

  # One shared ssh_user on every host (not labuserNN)
  vms = {
    for name in local.vm_name_list : name => {
      ssh_user = var.ssh_user
    }
  }
}
