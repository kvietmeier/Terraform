###===================================================================================###
#
#  File:  multi_map.variables.tf
#  Created By: Karl Vietmeier
#
#  Unique Azure clients via map; keys = short names. Name = vm_name_prefix + key.
#
###===================================================================================###

variable "existing_network_rg" {
  type = string
}

variable "existing_vnet_name" {
  type = string
}

variable "existing_subnet_name" {
  type = string
}

variable "resource_group_name" {
  type    = string
  default = "rg-lab-clients"
}

variable "location" {
  type    = string
  default = "westus3"
}

variable "vm_name_prefix" {
  type    = string
  default = "kv-"
}

variable "vms" {
  description = "Map of VM configs; key = short name (copper, lead, …)"
  type = map(object({
    vm_size              = string
    data_disk_count      = optional(number, 1)
    os_disk_storage_type = optional(string, "Premium_LRS")
  }))
}

variable "vm_size_default" {
  description = "Unused placeholder; sizes come from var.vms"
  type        = string
  default     = "Standard_E2bds_v5"
}

variable "disk_ctlr" {
  type    = string
  default = "NVMe"
}

variable "os_disk_caching" {
  type    = string
  default = "ReadWrite"
}

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
  type    = string
  default = "strata"
}

variable "secure_boot_enabled" {
  type    = bool
  default = false
}

variable "vtpm_enabled" {
  type    = bool
  default = true
}

variable "cloudinit_configfile" {
  type    = string
  default = "../../../scripts/cloud-init/cloud-init-universal.yaml"
}

variable "ssh_key_path" {
  type = string
}

locals {
  vms = {
    for short, spec in var.vms : "${var.vm_name_prefix}${short}" => spec
  }

  data_disks = {
    for pair in flatten([
      for name, spec in local.vms : [
        for i in range(spec.data_disk_count) : {
          key     = "${name}-disk${i}"
          vm_name = name
          lun     = 10 + i
        }
      ]
    ]) : pair.key => pair
  }
}
