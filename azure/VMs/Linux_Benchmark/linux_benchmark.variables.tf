###===================================================================================###
#   SPDX-License-Identifier: Apache-2.0
###=======================================================================i===========###
#  File:  db_benchmarking.variables.tf
#  Created By: Karl Vietmeier
#
#  Define variables used in main.tf
#
###===================================================================================###


###===================================================================================###
###  Infrastructure
###===================================================================================###

# Azure Region 
variable "region" { type = string }

# Misc dimensioning/scale parameters
variable "resource_prefix" { type = string }
variable "vm_prefix" { type = string }
variable "node_count" { type = number }


###===================================================================================###
###  Networking
###===================================================================================###

# Hub resources for vnet peering
variable "existing-rg" { type = string }
variable "existing-vnet" { type = string }

# Allow list for NSG
variable "whitelist_ips" {
  description = "A list of IP CIDR ranges to allow as clients. Do not use Azure tags like `Internet`."
  type        = list(string)
}

###--- IP Ranges
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

#variable "vm_size" { type = string }

# OS Image and Disk
variable "caching"       { type = string }
variable "sa_type"       { type = string }
variable "shutdown_time" { type = string }
variable "timezone"      { type = string }
variable "cloudinit"     { type = string }

# User Info
variable "username" { type = string }
variable "password" { type = string }
variable "ssh_key"  { type = string }

# Create map(object) for VM configs
variable "vmconfigs" {
  description = "List of vms to create and a unique configuration for each."
  type = map(object(
      {
        name      = string
        size      = string
        publisher = string
        offer     = string
        sku       = string
        ver       = string
        hostnum   = string   # For static IP
        #disks     = list(number)
      }
    )
  )
}


###==================================================================================###
# Environment (Tagging)
###==================================================================================###
variable "Environment" { type = string }



###===================================================================================###
#   Retrieve existing resources in Azure
###===================================================================================###

### Restricted to one Resource Group
# Resource Group
data "azurerm_resource_group" "existing-rg" {
  name = var.existing-rg
}

# Hub vNet
data "azurerm_virtual_network" "existing-vnet" {
  resource_group_name = data.azurerm_resource_group.existing-rg.name
  name                = var.existing-vnet
}

# Refer to them in maint.tf using: 
# data.azurerm_resource_group.hub-rg.name
# data.azurerm_resource_group.hub-rg.id
# data.azurerm_virtual_network.hub-vnet.name
# data.azurerm_virtual_network.hub-vnet.id
