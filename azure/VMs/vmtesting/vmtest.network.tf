###===================================================================================###
#   Copyright (C) 2022 Intel Corporation
#   SPDX-License-Identifier: Apache-2.0
###===================================================================================###
#
#  File:  network.tf
#  Created By: Karl Vietmeier
#
#  Purpose: Configure networking for VMs  
# 
###===================================================================================###

/* Put Usage Documentation here
  
  * Subnet configuration is managed by the cidrsubnets() function using a simple map
    referencing: subnet_id = azurerm_subnet.subnets[$key].id
    https://developer.hashicorp.com/terraform/language/functions/cidrsubnets

  This config: 
    * 1 vNIC
    * w/publicIP
    * NSG that filters on source IP
    * Peers vnet to a hub vnet
  
  ToDo:
    * Use existing NSG based on region
    * Use static IPs so they can be in Ansible inventory
    * Probably should be a module

*/

###===================================================================================###
#     Create Network Resources
###===================================================================================###

###--- Network Setup
# Create the vnet
resource "azurerm_virtual_network" "vnet" {
  resource_group_name = azurerm_resource_group.linuxvm_rg.name
  location            = azurerm_resource_group.linuxvm_rg.location
  name                = "${var.prefix}-vnet"
  address_space       = var.vnet_cidr
}

# Create Subnets 
resource "azurerm_subnet" "subnets" {
  resource_group_name  = azurerm_resource_group.linuxvm_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  
  # Parse map of subnets
  for_each         = var.subnets
  name             = each.key
  
  # Calculate subnet CIDRs from vnet CIDR
  address_prefixes = [cidrsubnet(var.vnet_cidr[0], 2, each.value)]

}


###===================================================================================###
#      Create a vnet peer to the hub vnet
###===================================================================================###
#  Syntax is important here -
#   1) Refer to the "source" resources in each peering block by name and the remote v
#      net resource by its id.
#   2) You match the vnet with its resource group in each peering block

# Spoke-2-Hub Peer
resource "azurerm_virtual_network_peering" "spoke2hub" {
  name = "peer-linuxvms2hub"
  # Source resources by name
  resource_group_name  = azurerm_resource_group.linuxvm_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  # Target vnet by ID
  remote_virtual_network_id = data.azurerm_virtual_network.hub-vnet.id
}

# Hub-2-Spoke Peer
resource "azurerm_virtual_network_peering" "hub2spoke" {
  name = "peer-hub2linuxvms"
  # Source resources by name
  resource_group_name  = data.azurerm_resource_group.hub-rg.name
  virtual_network_name = data.azurerm_virtual_network.hub-vnet.name
  # Target vnet by ID
  remote_virtual_network_id = azurerm_virtual_network.vnet.id
}


###===================================================================================###
###--- Public IPs
###===================================================================================###
resource "azurerm_public_ip" "pip" {
  name                = "${var.vm_name}-pip"
  domain_name_label   = var.vm_name
  allocation_method   = "Dynamic"
  location            = azurerm_resource_group.linuxvm_rg.location
  resource_group_name = azurerm_resource_group.linuxvm_rg.name
}


###===================================================================================###
#      Create a NIC with a public IP
###===================================================================================###
###    (Gets attached to the VM during creation of the VM)
resource "azurerm_network_interface" "primary" {
  name                          = "${var.vm_name}-nic"
  enable_accelerated_networking = "false"
  location                      = azurerm_resource_group.linuxvm_rg.location
  resource_group_name           = azurerm_resource_group.linuxvm_rg.name

  ip_configuration {
    name                          = "default"
    primary                       = true
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.subnets["default"].id
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}


###===================================================================================###
#      Create an NSG allowing SSH from my IP
###===================================================================================###
resource "azurerm_network_security_group" "ssh" {
  name                = "AllowInbound"
  location            = azurerm_resource_group.linuxvm_rg.location
  resource_group_name = azurerm_resource_group.linuxvm_rg.name
  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "SSH"
    priority                   = 100
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefixes    = var.whitelist_ips
    destination_port_range     = "22"
    destination_address_prefix = "*"
  }
  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "RDP"
    priority                   = 101
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefixes    = var.whitelist_ips
    destination_port_range     = "3389"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "mapnsg" {
  subnet_id                 = azurerm_subnet.subnets["default"].id
  network_security_group_id = azurerm_network_security_group.ssh.id
}

