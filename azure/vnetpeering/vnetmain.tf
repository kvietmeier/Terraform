###===============================#===================================================###
# This will Peer two existing VNets across regions 
###===============================#===================================================###

###===============================#===================================================###
###--- Configure the Azure Provider
###===================================================================================###
# Configure the Microsoft Azure Provider
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


# initiates source to destination peering between to existing vnets
resource "azurerm_virtual_network_peering" "source-to-destination" {
  name                         = "peering-to-${var.destination_peer.virtual_network_name}"
  resource_group_name          = data.azurerm_virtual_network.existing_source_vnet.resource_group_name
  virtual_network_name         = data.azurerm_virtual_network.existing_source_vnet.name
  remote_virtual_network_id    = data.azurerm_virtual_network.existing_source_vnet.id
  allow_virtual_network_access = var.allow_virtual_network_access
  allow_forwarded_traffic      = var.allow_forwarded_traffic
  allow_gateway_transit        = var.allow_gateway_transit
  use_remote_gateways          = var.use_remote_gateways
  depends_on                   = [data.azurerm_virtual_network.existing_source_vnet]
}

# initiates destination to source peering between to existing vnets
resource "azurerm_virtual_network_peering" "destination-to-source" {
  name                         = "peering-from-${var.source_peer.virtual_network_name}"
  resource_group_name          = data.azurerm_virtual_network.existing_destination_vnet.resource_group_name
  virtual_network_name         = data.azurerm_virtual_network.existing_destination_vnet.name
  remote_virtual_network_id    = data.azurerm_virtual_network.existing_destination_vnet.id
  allow_virtual_network_access = var.allow_virtual_network_access
  allow_forwarded_traffic      = var.allow_forwarded_traffic
  allow_gateway_transit        = var.allow_gateway_transit
  use_remote_gateways          = var.use_remote_gateways
  depends_on                   = [data.azurerm_virtual_network.existing_destination_vnet]
}