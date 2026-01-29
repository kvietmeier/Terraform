###===================================================================================###
#
#  File:  Template.tf
#  Created By: Karl Vietmeier
#
#  Terraform Module Code
#  Purpose:  Blank Template
# 
#  Files in Module:
#    main.tf
#    variables.tf
#    variables.tfvars
#
#  Usage:
#  terraform apply --auto-approve
#  terraform destroy --auto-approve
###===================================================================================###

/* 

Put Usage Documentation here

*/


# =========================================================================
# EXISTING RESOURCES (DATA SOURCES)
# =========================================================================

# 1. Existing Resource Group
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

# 2. Existing VNet
data "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

# 3. Existing Subnet
data "azurerm_subnet" "gateway_subnet" {
  name                 = "GatewaySubnet"
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.rg.name
}

# =========================================================================
# PUBLIC IPS (Active-Active requires two Standard SKUs)
# =========================================================================
resource "azurerm_public_ip" "pip0" {
  name                = "vpn-pip-0"
  location            = data.azurerm_resource_group.rg.location # Fixed
  resource_group_name = data.azurerm_resource_group.rg.name     # Fixed
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "pip1" {
  name                = "vpn-pip-1"
  location            = data.azurerm_resource_group.rg.location # Fixed
  resource_group_name = data.azurerm_resource_group.rg.name     # Fixed
  allocation_method   = "Static"
  sku                 = "Standard"
}

# =========================================================================
# AZURE VPN GATEWAY (Active-Active)
# =========================================================================
resource "azurerm_virtual_network_gateway" "vpngw" {
  name                = var.gateway_name
  location            = data.azurerm_resource_group.rg.location # Fixed
  resource_group_name = data.azurerm_resource_group.rg.name     # Fixed

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = true
  enable_bgp    = true
  sku           = "VpnGw1" 
  generation    = "Generation1"

  ip_configuration {
    name                          = "vnetGatewayConfig1"
    public_ip_address_id          = azurerm_public_ip.pip0.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = data.azurerm_subnet.gateway_subnet.id # Fixed (uses data)
  }

  ip_configuration {
    name                          = "vnetGatewayConfig2"
    public_ip_address_id          = azurerm_public_ip.pip1.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = data.azurerm_subnet.gateway_subnet.id # Fixed (uses data)
  }

  bgp_settings {
    asn = var.azure_asn
    peering_addresses {
      ip_configuration_name = "vnetGatewayConfig1"
      apipa_addresses       = [var.azure_apipa_bgp_a]
    }
    peering_addresses {
      ip_configuration_name = "vnetGatewayConfig2"
      apipa_addresses       = [var.azure_apipa_bgp_b]
    }
  }
}

# =========================================================================
# LOCAL NETWORK GATEWAYS (Represents GCP)
# =========================================================================
resource "azurerm_local_network_gateway" "gcp_gw0" {
  name                = "gcp-lng-0"
  location            = data.azurerm_resource_group.rg.location # Fixed
  resource_group_name = data.azurerm_resource_group.rg.name     # Fixed
  gateway_address     = var.gcp_pubip0 
  
  bgp_settings {
    asn                 = var.gcp_asn
    bgp_peering_address = var.gcp_apipa_bgp_a
  }
}

resource "azurerm_local_network_gateway" "gcp_gw1" {
  name                = "gcp-lng-1"
  location            = data.azurerm_resource_group.rg.location # Fixed
  resource_group_name = data.azurerm_resource_group.rg.name     # Fixed
  gateway_address     = var.gcp_pubip1 

  bgp_settings {
    asn                 = var.gcp_asn
    bgp_peering_address = var.gcp_apipa_bgp_b
  }
}

# =========================================================================
# CONNECTIONS
# =========================================================================
resource "azurerm_virtual_network_gateway_connection" "conn0" {
  name                = "azure-to-gcp-conn0"
  location            = data.azurerm_resource_group.rg.location # Fixed
  resource_group_name = data.azurerm_resource_group.rg.name     # Fixed

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vpngw.id
  local_network_gateway_id   = azurerm_local_network_gateway.gcp_gw0.id

  shared_key = var.shared_key
  enable_bgp = true
}

resource "azurerm_virtual_network_gateway_connection" "conn1" {
  name                = "azure-to-gcp-conn1"
  location            = data.azurerm_resource_group.rg.location # Fixed
  resource_group_name = data.azurerm_resource_group.rg.name     # Fixed

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vpngw.id
  local_network_gateway_id   = azurerm_local_network_gateway.gcp_gw1.id

  shared_key = var.shared_key
  enable_bgp = true
}