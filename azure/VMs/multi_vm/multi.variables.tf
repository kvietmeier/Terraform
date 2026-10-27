###===================================================================================###
#
#  File:  multi.variables.tf
#  Created By: Karl Vietmeier
#
#  Identical client pool — mirrors aws/ec2/multi_vm and gcp/VMs/multi_vm.
#  Default image: Azure Linux HPC (accept Marketplace terms once).
#
###===================================================================================###

### Existing networking

variable "existing_network_rg" {
  description = "Resource group where the vNet exists"
  type        = string
}

variable "existing_vnet_name" {
  description = "Name of the existing vNet"
  type        = string
}

variable "existing_subnet_name" {
  description = "Name of the subnet to attach to"
  type        = string
}

### VM fleet

variable "resource_group_name" {
  description = "New resource group for the client fleet"
  type        = string
  default     = "rg-lab-clients"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "westus3"
}

variable "vm_count" {
  description = "Number of VMs when vm_names is empty"
  type        = number
  default     = 3
}

variable "vm_name_prefix" {
  description = "Prefix applied to every VM name (e.g. kv- → kv-copper)"
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

variable "data_disk_count_per_vm" {
  description = "UltraSSD data disks attached per VM"
  type        = number
  default     = 1
}

variable "vm_size" {
  description = "Azure VM size (NVMe + UltraSSD capable)"
  type        = string
  default     = "Standard_E2bds_v5"
}

variable "disk_ctlr" {
  description = "Disk controller type"
  type        = string
  default     = "NVMe"
}

variable "os_disk_caching" {
  description = "OS disk caching"
  type        = string
  default     = "ReadWrite"
}

variable "os_disk_storage_type" {
  description = "OS disk storage account type"
  type        = string
  default     = "Premium_LRS"
}

### Azure Linux HPC image

variable "image_publisher" {
  type    = string
  default = "azure-hpc"
}

variable "image_offer" {
  type    = string
  default = "azurelinux-hpc"
}

variable "image_sku" {
  type    = string
  default = "3"
}

variable "image_version" {
  type    = string
  default = "latest"
}

variable "ssh_user" {
  description = "Admin / Ansible user (strata after universal cloud-init)"
  type        = string
  default     = "strata"
}

# Kept for older tfvars; prefer ssh_user
variable "admin_user" {
  description = "Deprecated alias for ssh_user"
  type        = string
  default     = null
  nullable    = true
}

variable "security_type" {
  type    = string
  default = "TrustedLaunch"
}

variable "secure_boot_enabled" {
  description = "Set false for unsigned kernel drivers"
  type        = bool
  default     = false
}

variable "vtpm_enabled" {
  type    = bool
  default = true
}

variable "cloudinit_configfile" {
  description = "Path to cloud-init yaml"
  type        = string
  default     = "../../../scripts/cloud-init/cloud-init-universal.yaml"
}

# Alias used by older tfvars
variable "cloud_init_path" {
  type     = string
  default  = null
  nullable = true
}

variable "ssh_key_path" {
  description = "Path to SSH public key"
  type        = string
}

locals {
  admin_username = coalesce(var.admin_user, var.ssh_user)
  cloudinit_path = coalesce(var.cloud_init_path, var.cloudinit_configfile)

  vm_name_list = length(var.vm_names) > 0 ? [
    for n in var.vm_names : "${var.vm_name_prefix}${n}"
    ] : [
    for i in range(var.vm_count) : format("%s%s%02d", var.vm_name_prefix, var.vm_base_name, i + 1)
  ]

}
