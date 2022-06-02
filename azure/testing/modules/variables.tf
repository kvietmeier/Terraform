


# Misc
variable "prefix" { type = string }
variable "suffix" { type = string }


###===================================================================================###
#   Network configuration parameters
###===================================================================================###


# Region list for NSGs
variable nsg_regions {
  description = "List of regions to place NSGs in"
  type        = list(string)
}

variable region_map {
  type = map
}

###===================================================================================###
#   Retrieve existing resources in Azure
###===================================================================================###
/* 
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


 */
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

