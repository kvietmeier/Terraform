###===================================================================================###
#  File:  testing.tf
#  Created By: Karl Vietmeier
#
#  Goal: Create a Hub-and-Spoke network topology with an existing Hub vnet
#        --- I have resources I need to access in the hub like Ansible and ADDS  
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

# Spoke-2-Hub Peer
resource "azurerm_virtual_network_peering" "spoke2hub" {
  name                      = "peer-spoke2hub"
  resource_group_name       = azurerm_resource_group.spoke-rg.name
  virtual_network_name      = azurerm_virtual_network.source.name
  remote_virtual_network_id = data.azurerm_virtual_network.hub-vnet.id
}

# Hub-2-Spoke Peer
resource "azurerm_virtual_network_peering" "hub2spoke" {
  name                      = "peer-hub2spoke"
  resource_group_name       = data.azurerm_resource_group.hub-rg.name
  virtual_network_name      = data.azurerm_virtual_network.hub-vnet.name
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


