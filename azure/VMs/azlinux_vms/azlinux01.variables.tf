###===================================================================================###
# SUMMARY:
#   Input variables for the Linux VM deployment.
#   Defines networking targets, VM sizing, storage configs, and image details.
#
# USAGE:
#   These are defaults. Override specific values in 'terraform.tfvars'.
#
# LICENSE:
#   Copyright 2025 Karl Vietmeier / KCV Consulting
#   SPDX-License-Identifier: Apache-2.0
#
###===================================================================================###

### Existing Resources
variable "existing_network_rg" {
  description = "The Resource Group where the vNet exists"
  type        = string
}

variable "existing_vnet_name" {
  description = "The name of the existing vNet"
  type        = string
}

variable "existing_subnet_name" {
  description = "The name of the subnet to attach to"
  type        = string
}


### VM Resources
variable "resource_group_name" {
  default = "rg-deleteme-tf"
}

variable "location" {
  default = "westus3"
}

variable "vm_count" {
  default = 2
}

variable "data_disk_count_per_vm" {
  default = 1
}

variable "vm_size" {
  default = "Standard_E2bds_v5" # Supports NVMe and UltraSSD
}

# OS Disk - 
variable "disk_ctlr" {
  description = "Disk Controller Type"
  type        = string
  default     = "NVME"
}
variable "os_disk_caching" {
  description = "Caching type for the OS Disk (ReadWrite, ReadOnly, None)"
  type        = string
  default     = "ReadWrite"
}

variable "os_disk_storage_type" {
  description = "Storage Account type for the OS Disk (Standard_LRS, Premium_LRS, StandardSSD_LRS)"
  type        = string
  default     = "Premium_LRS"
}


### Azure Linux
variable "image_publisher" {
  description = "The publisher of the image (e.g., azure-hpc)"
  type        = string
  default     = "azure-hpc"
}

variable "image_offer" {
  description = "The offer of the image (e.g., azurelinux-hpc)"
  type        = string
  default     = "azurelinux-hpc"
}

variable "image_sku" {
  description = "The SKU of the image (e.g., 3)"
  type        = string
  default     = "3"
}

variable "image_version" {
  description = "The version of the image (e.g., latest)"
  type        = string
  default     = "latest"
}

variable "admin_user" {
  description = "Admin user"
  type        = string
  default     = "azureuser"
}


### System Config
variable "cloud_init_path" {
  # Update this path to your real cloud-init file
  default = "aws-cloud-init-multiOS.yaml"
}

### User Variables
variable "ssh_key_path" {
  # Update this path to your real key file
  default = "C:/Users/karl.vietmeier/.ssh/id_rsa.pub"
}