###==================================================================================###
#  File:  aadds.vars.tf
#  Created By: Karl Vietmeier
#
#  Define variables used in main.tf
#
###==================================================================================###


###===================================================================================###
###  Infrastructure
###===================================================================================###

# Azure Region 
variable "region" { type = string }
variable "prefix" { type = string }

# Misc dimensioning/scale parameters
variable "node_count"    { type = number }
variable "timezone"      { type = string }

# Directory/User Parameters
variable "aadds_name"   { type = string }
variable "aadds-group"  { type = string }
variable "dcadmin_upn"  { type = string }
variable "display_name" { type = string }
variable "password"     { type = string }
variable "aadds_sku"    { type = string }
variable "domain_name"  { type = string }


# Need this for Service Principle
variable "domain_controller_services_id" {
  type        = string
  description = "Domain Controller Services Published Application ID."
  # ID for public Azure
  # Other clouds use the ID: 6ba9a5d4-8456-4118-b521-9c5ca10cdf84
  default = "2565bd9d-da50-47d4-8b85-4c97f669dc36"
}



###===================================================================================###
###  Networking
###===================================================================================###

# IP Ranges
variable "vnet_cidr" {type = list(string)}

# Simple map with a default subnet - source for cidrsubnets()
variable "subnets" {
  type = map(string)
  default = {
    "default" = "0"
  }
}

###==================================================================================###
#   Environment (Tagging)
###==================================================================================###
variable "Environment" { type = string }



###===================================================================================###
#   Retrieve existing resources in Azure
###===================================================================================###

### Right now we just need the Hub vNet to peer to.


# Refer to them in maint.tf using: 
# data.azurerm_resource_group.hub-rg.name
# data.azurerm_resource_group.hub-rg.id
# data.azurerm_virtual_network.hub-vnet.name
# data.azurerm_virtual_network.hub-vnet.id



