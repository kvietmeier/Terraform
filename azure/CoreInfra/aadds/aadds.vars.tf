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

# Misc dimensioning/scale parameters
variable "prefix" { type = string }
variable "node_count" { type = number }

# Directory/User Parameters
variable "aadds-group" { type = string }
variable "user_upn" { type = string }
variable "display_name" { type = string }
variable "password" { type = string }
variable "aadds_sku" { type = string }
variable "domain" { type = string }


###===================================================================================###
###  Networking
###===================================================================================###

# IP Ranges
variable "vnet_cidr" {type = list(string)}
variable "subnet_cidr" {type = list(string)}
variable "dns_servers" {type = list(string)}

# Allow list for NSG
variable whitelist_ips {
  description = "A list of IP CIDR ranges to allow as clients. Do not use Azure tags like `Internet`."
  type        = list(string)
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



