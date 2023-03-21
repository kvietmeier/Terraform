###===================================================================================###
#   Copyright (C) 2022 Intel Corporation
#   SPDX-License-Identifier: Apache-2.0
###===================================================================================###
#  File:  linux.vm.variables.tf
#  Created By: Karl Vietmeier
#
#  Terraform Template Code
#  Purpose: Create a single Linux VM
#
#  Files in Module:
#    linux.vm.main.tf
#    linux.vm.variables.tf
#    linux.vm.variables.tfvars
#    linux.vm.variables.tfvars.txt
#
#  Usage:
#  terraform apply --auto-approve -var-file=".\linux.vm.variables.tfvars"
#  terraform destroy --auto-approve -var-file=".\linux.vm.variables.tfvars"
#
###===================================================================================###


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

# Allow list for NSG
variable "whitelist_ips" {
  description = "A list of IP CIDR ranges to allow as clients. Do not use Azure tags like `Internet`."
  type        = list(string)
}

# Hub resources for vnet peering
variable "hub-rg" { type = string }
variable "hub-vnet" { type = string }

# vNet address spaces/cidrs
variable "vnet_cidr" { type = list(string) }

# Simple map with a default subnet - source for cidrsubnets()
variable "subnets" {
  type = map(string)
  default = {
    "default" = "0"
  }
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



###===================================================================================###
#   Retrieve existing resources in Azure
###===================================================================================###

### Right now we just need the Hub vNet to peer to.
# Resource Groups
data "azurerm_resource_group" "hub-rg" {
  name = var.hub-rg
}

# Hub vNet to peer to
data "azurerm_virtual_network" "hub-vnet" {
  resource_group_name = data.azurerm_resource_group.hub-rg.name
  name                = var.hub-vnet
}

# Refer to them in maint.tf using: 
# data.azurerm_resource_group.hub-rg.name
# data.azurerm_resource_group.hub-rg.id
# data.azurerm_virtual_network.hub-vnet.name
# data.azurerm_virtual_network.hub-vnet.id


