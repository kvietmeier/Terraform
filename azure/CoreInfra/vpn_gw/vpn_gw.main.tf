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


###===================================================================================###
#     Start creating infrastructure resources
###===================================================================================###

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# =========================================================================
# NETWORK & SUBNETS
# =========================================================================
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.10.0.0/16"] # Adjust as needed
}

resource "azurerm_subnet" "gateway_subnet" {
  name                 = "GatewaySubnet" # Must be exactly this name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.255.0/27"]
}

# =========================================================================
# PUBLIC IPS (Active-Active requires two Standard SKUs)
# =========================================================================
resource "azurerm_public_ip" "pip0" {
  name                = "vpn-pip-0"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "pip1" {
  name                = "vpn-pip-1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# =========================================================================
# AZURE VPN GATEWAY (Active-Active)
# =========================================================================
resource "azurerm_virtual_network_gateway" "vpngw" {
  name                = var.gateway_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = true
  enable_bgp    = true
  sku           = "VpnGw1" # Or VpnGw2AZ depending on needs
  generation    = "Generation1"

  ip_configuration {
    name                          = "vnetGatewayConfig1"
    public_ip_address_id          = azurerm_public_ip.pip0.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gateway_subnet.id
  }

  ip_configuration {
    name                          = "vnetGatewayConfig2"
    public_ip_address_id          = azurerm_public_ip.pip1.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gateway_subnet.id
  }

  bgp_settings {
    asn = var.azure_asn
    # Custom APIPA BGP IPs (matching your script)
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
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  gateway_address     = var.gcp_pubip0 # From GCP Output
  
  bgp_settings {
    asn                 = var.gcp_asn
    bgp_peering_address = var.gcp_apipa_bgp_a
  }
}

resource "azurerm_local_network_gateway" "gcp_gw1" {
  name                = "gcp-lng-1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  gateway_address     = var.gcp_pubip1 # From GCP Output

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
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vpngw.id
  local_network_gateway_id   = azurerm_local_network_gateway.gcp_gw0.id

  shared_key = var.shared_key
  enable_bgp = true
  
  # Ensure Azure Instance 0 talks to GCP Interface 0
  # Note: Azure handles active-active routing automatically, 
  # but distinct connections ensure 1:1 tunnel mapping clarity.
}

resource "azurerm_virtual_network_gateway_connection" "conn1" {
  name                = "azure-to-gcp-conn1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vpngw.id
  local_network_gateway_id   = azurerm_local_network_gateway.gcp_gw1.id

  shared_key = var.shared_key
  enable_bgp = true
}