##
# Existing Vnet Data 
##


data "azurerm_virtual_network" "existing_source_vnet" {             
  resource_group_name = lookup(var.source_peer, "resource_group_name")
  name                = lookup(var.source_peer, "virtual_network_name")
}

data "azurerm_subnet" "src_subnet" {
  name                 = lookup(var.source_peer, "name")
  virtual_network_name = lookup(var.source_peer, "virtual_network_name")
  resource_group_name  = lookup(var.source_peer, "resource_group_name")
}

data "azurerm_virtual_network" "existing_destination_vnet" {
  resource_group_name = lookup(var.destination_peer, "resource_group_name")
  name                = lookup(var.destination_peer, "virtual_network_name")
}

data "azurerm_subnet" "dtn_subnet" {
  name                 = lookup(var.destination_peer, "name")
  virtual_network_name = lookup(var.destination_peer, "virtual_network_name")
  resource_group_name  = lookup(var.destination_peer, "resource_group_name")
}