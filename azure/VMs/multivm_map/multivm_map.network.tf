###===================================================================================###
#   Copyright (C) 2022 Intel Corporation
#   SPDX-License-Identifier: Apache-2.0
###===================================================================================###
#
#  File:  multivm.network.tf
#  Created By: Karl Vietmeier
#
#  Purpose:  Setup networking for VMs
# 
###===================================================================================###

/* 
   Put Usage Documentation here
*/


###===================================================================================###
#     Start creating network resources
###===================================================================================###

# Create the vnet
resource "azurerm_virtual_network" "vnet" {
  location            = azurerm_resource_group.multivm_rg.location
  resource_group_name = azurerm_resource_group.multivm_rg.name
  name                = "${var.resource_prefix}-network"
  address_space       = var.vnet_cidr
}

# 2 Subnets - one for each NIC
resource "azurerm_subnet" "subnets" {
  resource_group_name  = azurerm_resource_group.multivm_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name

  # Parse map of subnets
  for_each         = var.subnets
  name             = each.key

  # [0] use first element in cidr list, 2 each subnet is /24, the value in subnets is the index
  address_prefixes = [cidrsubnet(var.vnet_cidr[0], 2, each.value)]
}


#--- Note - I am using "${var.vm_prefix}-${format("%02d", count.index)}" throughout
#--- to create consistent naming of resources.
#--- If I use a map, I can create named VM configs and use that

# Create the Public IPs
resource "azurerm_public_ip" "public_ips" {
  location            = azurerm_resource_group.multivm_rg.location
  resource_group_name = azurerm_resource_group.multivm_rg.name

  for_each = var.vmconfigs
  name              = "${each.value.name}-PublicIP"
  allocation_method = "Dynamic"
  
  # Give it some uniqueness
  domain_name_label   = "${each.value.name}-${random_id.pipid.hex}"
}

###- Create 2 NICs - one primary w/PubIP, one internal with SRIOV enabled
resource "azurerm_network_interface" "primary" {
  location                      = azurerm_resource_group.multivm_rg.location
  resource_group_name           = azurerm_resource_group.multivm_rg.name

  for_each = var.vmconfigs
  name     = "${each.value.name}-PrimaryNIC"
  enable_accelerated_networking = "false"

  ip_configuration {
    # This is the "management NIC" with a PublicIP 
    primary                       = true
    name                          = "${each.value.name}-PrimaryCFG"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.subnets["default"].id
    public_ip_address_id          = azurerm_public_ip.public_ips[each.key].id
  }
}

resource "azurerm_network_interface" "internal" {
  # This NIC is for internal/private networking 
  location                      = azurerm_resource_group.multivm_rg.location
  resource_group_name           = azurerm_resource_group.multivm_rg.name
  
  for_each = var.vmconfigs
  name     = "${each.value.name}-InternalNIC"
  
  enable_accelerated_networking = "true"

  ip_configuration {
    primary                       = false
    name                          = "${each.value.name}-InternalCFG"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.subnets["internal"].id
    #private_ip_address_allocation = "Static"
    #private_ip_address            = element(var.subnet2_ips[*].id, count.index)
  }
}


###- Create an NSG allowing SSH from my IP
###- TBD - use my existing NSGs 
resource "azurerm_network_security_group" "upfnsg" {
  location            = azurerm_resource_group.multivm_rg.location
  resource_group_name = azurerm_resource_group.multivm_rg.name
  name                = "AllowInbound"
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

# Map the NSG
resource "azurerm_subnet_network_security_group_association" "mapnsg" {
  subnet_id                 = azurerm_subnet.subnets["default"].id
  network_security_group_id = azurerm_network_security_group.upfnsg.id
}

### Create a vnet peer to the hub vnet
#   (Optional) - I do this because I have a "Linux Tools" VM in my hub vnet. 
# Syntax is important here -
# 1) Refer to the "source" resources in each peering block by name and the remote v
#    net resource by its id.
# 2) You match the vnet with its resource group in each peering block

# Spoke-2-Hub Peer
resource "azurerm_virtual_network_peering" "spoke2hub" {
  name = "peer-spoke2hub"
  # Source resources by name
  resource_group_name  = azurerm_resource_group.multivm_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  # Target vnet by ID
  remote_virtual_network_id = data.azurerm_virtual_network.hub-vnet.id
}

# Hub-2-Spoke Peer
resource "azurerm_virtual_network_peering" "hub2spoke" {
  name = "peer-hub2spoke"
  # Source resources by name
  resource_group_name  = data.azurerm_resource_group.hub-rg.name
  virtual_network_name = data.azurerm_virtual_network.hub-vnet.name
  # Target vnet by ID
  remote_virtual_network_id = azurerm_virtual_network.vnet.id
}


