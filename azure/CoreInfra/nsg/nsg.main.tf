###===================================================================================###
#   Copyright (C) 2022 Intel Corporation
#   SPDX-License-Identifier: Apache-2.0
###===================================================================================###
#  File:  main.tf
#  Created By: Karl Vietmeier
#
#  Terraform Template Code
#  Purpose: Manage the Network Security Groups in a Subscription
#
#  This module uses map variables and for_each
# 
###===================================================================================###


# Create resource groups from a map
resource "azurerm_resource_group" "regionalrgs" {
  for_each  = var.region_map
  location  = "${each.value}"
  name      = "${var.prefix}-${each.key}-${var.suffix}"
}

# Create the NSG resources for each resource group/region
resource "azurerm_network_security_group" "default-nsg" {
  for_each             = var.region_map
  location             = "${each.value}"
  resource_group_name  = azurerm_resource_group.regionalrgs[each.key].name
  name                 = "${each.key}-InboundNSG"

# A "bulk" rule to allow access to a set of standard services (FTP, SSH, RDP, SMB, etc)
# We want the same rule for all regions - this rule filters incoming traffic on the source IP
  security_rule {
    name                        = "InterNetFilter"
    access                      = "Allow"
    direction                   = "Inbound"
    priority                    = 100
    protocol                    = "*"
    source_port_range           = "*"
    source_address_prefixes     = "${var.whitelist_ips}"
    destination_port_ranges     = "${var.destination_ports}"
    destination_address_prefix  = "*"
  }

}
