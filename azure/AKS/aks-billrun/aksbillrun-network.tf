###===================================================================================###
#   Copyright (C) 2022 Intel Corporation
#   SPDX-License-Identifier: Apache-2.0
###===================================================================================###
#
#  File:  aksbillrun-network.tf
#  Created By: Karl Vietmeier
#
#  Terraform Module Code
#  Purpose: Configure networking for AKS cluster
# 
###===================================================================================###

/* Put Usage Documentation here */

###===================================================================================###
#     Create Network Resources
###===================================================================================###

###--- Network Setup
# Create the vnet
resource "azurerm_virtual_network" "vnet" {
  resource_group_name = azurerm_resource_group.aks-rg.name
  location            = azurerm_resource_group.aks-rg.location
  name                = "${var.cluster_prefix}-vnet"
  address_space       = var.vnet_cidr
}

# Create Subnets 
resource "azurerm_subnet" "subnets" {
  resource_group_name  = azurerm_resource_group.aks-rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  
  # Create subnets based on number of CIDRs defined in .tfvars
  # for_each = { for subnet in var.subnets : subnet.name => subnet.address_prefixes }

  for_each = { for each in var.subnets: each.name => each }
    name             = each.value.name
    address_prefixes = [each.value.cidr]

  /* Replace above -   
  # Parse map of subnets
  for_each         = var.subnets
  name             = each.key
  
  # Calculate subnet CIDRs from vnet CIDR
  address_prefixes = [cidrsubnet(var.vnet_cidr[0], 2, each.value)]
  */

}


###--- Create a vnet peer to the hub vnet
# Syntax is important here -
# 1) Refer to the "source" resources in each peering block by name and the remote v
#    net resource by its id.
# 2) You match the vnet with its resource group in each peering block

# Spoke-2-Hub Peer
resource "azurerm_virtual_network_peering" "spoke2hub" {
  name                      = "peer-aks2hub"
  # Source resources by name
  resource_group_name  = azurerm_resource_group.aks-rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  # Target vnet by ID
  remote_virtual_network_id = data.azurerm_virtual_network.hub-vnet.id
}

# Hub-2-Spoke Peer
resource "azurerm_virtual_network_peering" "hub2spoke" {
  name                      = "peer-hub2aks"
  # Source resources by name
  resource_group_name       = data.azurerm_resource_group.hub-rg.name
  virtual_network_name      = data.azurerm_virtual_network.hub-vnet.name
  # Target vnet by ID
  remote_virtual_network_id = azurerm_virtual_network.vnet.id
}
