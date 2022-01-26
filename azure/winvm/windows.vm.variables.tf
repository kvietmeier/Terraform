###===================================================================================###
#  File:  windows.vm.variables.tf
#  Created By: Karl Vietmeier
#
#  Terraform Template Code
#  Purpose: Create a single Windows VM
#
#  Files in Module:
#    windows.vm.main.tf
#    windows.vm.variables.tf
#    windows.vm.variables.tfvars
#    windows.vm.variables.tfvars.txt
#
#  Usage:
#  terraform apply --auto-approve -var-file=".\windows.vm.variables.tfvars"
#  terraform destroy --auto-approve -var-file=".\windows.vm.variables.tfvars"
#
###===================================================================================###

#
#
###==================================================================================###

variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  type        = string
}

variable "region" {
  description = "The Azure Region in which all resource will be created."
  type        = string
}

variable "vm_name" { type = string }

###==================================================================================###
###     Network Configurations
###==================================================================================###

# Address list for NSG
variable whitelist_ips {
  description = "Restrict access to the subnet to a defined set of CIDR blocks and IPs"
  type        = list(string)
}

variable vnet_cidr {
  description = "CIDR definition for the vnet"
  type        = list(string)
}

variable subnet01_cidr {
  description = "CIDR definition for the subnet"
  type        = list(string)
}

variable subnet02_cidr {
  description = "CIDR definition for the subnet"
  type        = list(string)
}


###==================================================================================###
###     VM specific information
###==================================================================================###

variable "vm_size" { type = string }

# OS Image and Disk
variable "publisher" { type = string }
variable "offer" { type = string }
variable "sku" { type = string }
variable "ver" { type = string }
variable "caching" { type = string }
variable "sa_type" { type = string }

# For Auto Shutdown
variable "shutdown_time" { type = string }
variable "timezone" { type = string }

# User Info
variable "username" { type = string }
variable "password" { type = string }
