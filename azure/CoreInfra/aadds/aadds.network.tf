###===================================================================================###
#   Copyright (C) 2022 Intel Corporation
#   SPDX-License-Identifier: Apache-2.0
###===================================================================================###
#
#  File:  aadds.network.tf
#  Created By: Karl Vietmeier
#
#  Terraform Module Code
#  Purpose: Create Network resources
# 
###===================================================================================###

/* 

Put Usage Documentation here

*/

###===================================================================================###
###    An AAD DS Instance needs an isolated vnet and subnet that you later peer to.
###===================================================================================###

# Create a vnet and subnet: (with DNS servers - required for the Domain Services)
resource "azurerm_virtual_network" "aadds-vnet" {
  resource_group_name = azurerm_resource_group.aadds-rg.name
  location            = azurerm_resource_group.aadds-rg.location
  
  name                = "${var.prefix}-vnet"
  address_space       = "${var.vnet_cidr}"
  #dns_servers         = "${var.dns_servers}"
}

resource "azurerm_subnet" "aadds-subnet" {
  resource_group_name  = azurerm_resource_group.aadds-rg.name
  
  virtual_network_name = azurerm_virtual_network.aadds-vnet.name
  
  # Parse map of subnets
  for_each         = var.subnets
  name             = each.key
  
  # [0] use first element in cidr list, 2 each subnet is /24, the value in subnets is the index
  address_prefixes     = [cidrsubnet(var.vnet_cidr[0], 2, each.value)]
}

# Create NSG
# 
resource "azurerm_network_security_group" "aadds-nsg" {
  location            = azurerm_resource_group.aadds-rg.location
  resource_group_name = azurerm_resource_group.aadds-rg.name
  
  name                = "${var.prefix}-nsg"
  security_rule {
    name                       = "AllowSyncWithAzureAD"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "AzureActiveDirectoryDomainServices"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "AllowRD"
    priority                   = 201
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "CorpNetSaw"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "AllowPSRemoting"
    priority                   = 301
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5986"
    source_address_prefix      = "AzureActiveDirectoryDomainServices"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "AllowLDAPS"
    priority                   = 401
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "636"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Associate the NSG to the Subnet
resource azurerm_subnet_network_security_group_association "nsg-map" {
  subnet_id                 = azurerm_subnet.aadds-subnet["default"].id
  network_security_group_id = azurerm_network_security_group.aadds-nsg.id
}

