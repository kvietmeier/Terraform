####===================================================================================###
#   Copyright (C) 2022 Intel Corporation
#   SPDX-License-Identifier: Apache-2.0
###===================================================================================###
#
#  File:  variables.tf
#  Created By: Karl Vietmeier
#
#  Variable definitions with defaults
#
###===================================================================================###


variable "location" {
  description = "Region to deploy resources"
  default     = "westus2"
}

###===================================================================================###
#   Retrieve existing resources in Azure
###===================================================================================###

# AKS Cluster info
data "azurerm_kubernetes_cluster" "credentials" {
  name                = "${var.cluster_name}"
  resource_group_name = azurerm_resource_group.aks-rg.name
}

# Resource Group
data "azurerm_resource_group" "aks-rg" {
  name = "${var.aks-rg}"
}

/* # Hub vNet to peer to
data "azurerm_virtual_network" "hub-vnet" {
  resource_group_name = data.azurerm_resource_group.hub-rg.name
  name = "${var.hub-vnet}"
}
*/

# Refer to them in maint.tf using: 
# data.azurerm_resource_group.hub-rg.name
# data.azurerm_resource_group.hub-rg.id
# data.azurerm_virtual_network.hub-vnet.name
# data.azurerm_virtual_network.hub-vnet.id