###===================================================================================###
#  File:  testing.tf
#  Created By: Karl Vietmeier
#
#  Goal: Create a Hub-and-Spoke network topology with an existing Hub vnet
#        --- You may have resources in the hub like an Ansible server and ADD DS  
# 
#  Usage:
#  terraform apply --auto-approve
#
###===================================================================================###

###===============================#===================================================###
###--- Configure the Azure Provider
###      Using environment variables
###===================================================================================###
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}

provider "azurerm" {
  features {}
}


###===================================================================================###
#   1.)  Retrieve existing resources in Azure
###===================================================================================###

# Resource Groups
data "azurerm_resource_group" "hub-rg" {
  name = "Coreinfra-rg"
}

# Hub vNet to peer to
data "azurerm_virtual_network" "hub-vnet" {
  resource_group_name = data.azurerm_resource_group.hub-rg.name
  name = "CoreInfraHub-vnet"
}


###===================================================================================###
#   2.)  Create spoke vnet and resource group
###===================================================================================###

# resource group
resource "azurerm_resource_group" "spoke-rg" {
  location = "West US 2"
  name     = "sourcenet-rg"
}

# vnet to peer to the hub
resource "azurerm_virtual_network" "source" {
  name                = "source_vnet"
  resource_group_name = azurerm_resource_group.spoke-rg.name
  location            = azurerm_resource_group.spoke-rg.location
  address_space       = ["10.11.0.0/16"]
}


###===================================================================================###
#   3.)  Create the peering
###===================================================================================###

# Syntax is important here -
# 1) Refer to the "source" resources in each peering block by name and the remote vnet resource by its id.
# 2) You match the vnet with its resource group in each peering block

# Spoke-2-Hub Peer
resource "azurerm_virtual_network_peering" "spoke2hub" {
  name                      = "peertest1-spoke2hub"
  # Spoke source resources by name
  resource_group_name       = azurerm_resource_group.spoke-rg.name
  virtual_network_name      = azurerm_virtual_network.source.name
  # Hub target vnet by ID
  remote_virtual_network_id = data.azurerm_virtual_network.hub-vnet.id
}

# Hub-2-Spoke Peer
resource "azurerm_virtual_network_peering" "hub2spoke" {
  name                      = "peertest1-hub2spoke"
  # Hub source resources by name
  resource_group_name       = data.azurerm_resource_group.hub-rg.name
  virtual_network_name      = data.azurerm_virtual_network.hub-vnet.name
  # Spoke target vnet by ID
  remote_virtual_network_id = azurerm_virtual_network.source.id
}


###===================================================================================###
###--- Output the values for debugging
###===================================================================================###

output "rg-id" {
  value = data.azurerm_resource_group.hub-rg.id
}

output "existing-vnet-id" {
  value = data.azurerm_virtual_network.hub-vnet.id
}

output "existing-vnet-name" {
  value = data.azurerm_virtual_network.hub-vnet.name
}

output "source-vnet-id" {
  value = azurerm_virtual_network.source.id
}

output "source-vnet-name" {
  value = azurerm_virtual_network.source.name
}


