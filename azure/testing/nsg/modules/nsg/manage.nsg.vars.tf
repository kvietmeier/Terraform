


# Region/s
variable "region" { type = string }

# Misc
variable "tf_prefix" { type = string }


###===================================================================================###
#   Network configuration parameters
###===================================================================================###

# Hub resources for vnet peering
variable "westus2-rg" {type = string}
variable "eastus2-rg" {type = string}

# Need this?
#variable "hub-vnet" {type = string}

# Allow list for NSG
variable whitelist_ips {
  description = "A list of IP CIDR ranges to allow as clients. Do not use Azure tags like `Internet`."
  type        = list(string)
}

# Region list for NSGs
variable nsg_regions {
  description = "List of regions to place NSGs in"
  type        = list(string)
}

# Destination Port list
variable destination_ports {
  description = "A list of standard network services: SSH, FTP, RDP, SMP, etc."
  type        = list(string)
}



###===================================================================================###
#   Retrieve existing resources in Azure
###===================================================================================###

# Resource Groups
data "azurerm_resource_group" "westus-rg" {
  name = "${var.westus-rg}"
}

data "azurerm_resource_group" "westus2-rg" {
  name = "${var.westus2-rg}"
}

data "azurerm_resource_group" "westus3-rg" {
  name = "${var.westus3-rg}"
}

data "azurerm_resource_group" "eastus-rg" {
  name = "${var.eastus-rg}"
}

data "azurerm_resource_group" "eastus2-rg" {
  name = "${var.eastus2-rg}"
}

data "azurerm_resource_group" "centralus-rg" {
  name = "${var.centralus-rg}"
}



/* 

# Hub vNet - don't need this right now
data "azurerm_virtual_network" "hub-vnet" {
  resource_group_name = data.azurerm_resource_group.hub-rg.name
  name = "${var.hub-vnet}"
}


Refer to them in main.tf using: 
data.azurerm_resource_group.hub-rg.name
data.azurerm_resource_group.hub-rg.id
data.azurerm_virtual_network.hub-vnet.name
data.azurerm_virtual_network.hub-vnet.id
*/

