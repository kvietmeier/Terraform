###===================================================================================###
#   Copyright (C) 2022 Intel Corporation
#   SPDX-License-Identifier: Apache-2.0
###=======================================================================i===========###
#  File:  variables.tf
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
variable "hub-rg" { type = string }
variable "hub-vnet" { type = string }

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


# - not used anymore
#variable "subnet_cidrs" { type = list(string) }
#variable "subnet1_ips" { type = list(string) }
#variable "subnet2_ips" { type = list(string) }


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
variable "shutdown_time" { type = string }
variable "timezone" { type = string }
variable "cloudinit" { type = string }

# User Info
variable "username" { type = string }
variable "password" { type = string }
variable "ssh_key" { type = string }

# Create map(object) for VM configs
variable "vmconfigs" {
  description = "List of vms to create and the configuration for each."
  type = map(object(
      {
        name    = string
        size    = string
        hostnum = string   # For static IP
        #disks   = list(number)
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



