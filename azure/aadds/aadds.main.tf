###===================================================================================###
#  File:  aadds.main.tf
#  Created By: Karl Vietmeier
#  From: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/active_directory_domain_service
#
#  Status:  In Progress
#
#  Terraform Template Code
#  Purpose: Create an Azure Active Directory Domain Services Instance
# 
#  Files in Module:
#    aadds.main.tf
#    aadds.variables.tf
#    aadds.variables.tfvars
#
#  Usage:
#  terraform apply --auto-approve -var-file=".\variables.tfvars"
#  terraform destroy --auto-approve -var-file=".\variables.tfvars"
#
###===================================================================================###

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

###===================================================================================###
#     Start creating infrastructure resources
###===================================================================================###

resource "azurerm_resource_group" "aadds-rg" {
  name     = "${var.prefix}-rg"
  location = var.region
}


###===================================================================================###
###    Networking Section
###===================================================================================###

# Create a vnet
resource "azurerm_virtual_network" "aadds-vnet" {
  name                = "${var.prefix}-vnet"
  address_space       = "${var.vnet_cidr}"
  location            = azurerm_resource_group.aadds-rg.location
  resource_group_name = azurerm_resource_group.aadds-rg.name
}

resource "azurerm_subnet" "aadds-subnet" {
  name                 = "subnet01"
  address_prefixes     = "${var.subnet01_cidr}"
  resource_group_name = azurerm_resource_group.aadds-rg.name
  virtual_network_name = azurerm_virtual_network.aadds-vnet
}

resource "azurerm_network_security_group" "aadds-nsg" {
  name                = "aadds-nsg"
  location            = azurerm_resource_group.aadds-rg.location
  resource_group_name = azurerm_resource_group.aadds-rg.name

  security_rule {
    name                       = "AllowSyncWithAzureAD"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "AzureActiveDirectoryDomainServices"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowRD"
    priority                   = 201
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "CorpNetSaw"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowPSRemoting"
    priority                   = 301
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5986"
    source_address_prefix      = "AzureActiveDirectoryDomainServices"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowLDAPS"
    priority                   = 401
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "636"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource azurerm_subnet_network_security_group_association "nsg-map" {
  subnet_id                 = azurerm_subnet.aadds-subnet.id
  network_security_group_id = azurerm_network_security_group.aadds-nsg.id
}


###===================================================================================###
###    AAD DS Creation Section
###===================================================================================###

resource "azuread_group" "dc_admins" {
  display_name = "${var.aadds-group}"
}


resource "azuread_user" "admin" {
  user_principal_name = "${var.user_upn}"
  display_name        = "${var.display_name}"
  password            = "${var.password}"
}

resource "azuread_group_member" "admin" {
  group_object_id  = azuread_group.dc_admins.object_id
  member_object_id = azuread_user.admin.object_id
}

resource "azuread_service_principal" "example" {
  application_id = "2565bd9d-da50-47d4-8b85-4c97f669dc36" // published app for domain services
}

resource "azurerm_active_directory_domain_service" "example" {
  name                  = "aadds-domain"
  location              = azurerm_resource_group.aadds-rg.location
  resource_group_name   = azurerm_resource_group.aadds-rg.name

  domain_name           = "${var.domain}"
  sku                   = "${var.aadds_sku}"
  filtered_sync_enabled = true

  initial_replica_set {
    subnet_id = azurerm_subnet.aadds-subnet.id
  }

  notifications {
    notify_dc_admins      = true
    notify_global_admins  = true
  }

  security {
    sync_kerberos_passwords = true
    sync_ntlm_passwords     = true
    sync_on_prem_passwords  = true
  }

  tags = {
    Environment = "prod"
  }

  depends_on = [
    azuread_service_principal.example,
    azurerm_subnet_network_security_group_association.deploy,
  ]
}