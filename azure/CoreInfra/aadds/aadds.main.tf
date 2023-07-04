###===================================================================================###
#   Copyright (C) 2022 Intel Corporation
#   SPDX-License-Identifier: Apache-2.0
###===================================================================================###

/* Documentation/Notes
  
  File:  aadds.main.tf
  Created By: Karl Vietmeier
  From: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/active_directory_domain_service
        https://registry.terraform.io/providers/hashicorp/azuread/latest/docs
  
  Purpose: Create an Azure Active Directory Domain Services Instance
 
  Docs are incomplete! - You need to add API Permissions to the Service Principle for this to work
  https://github.com/hashicorp/terraform-provider-azuread/issues/657
  https://github.com/hashicorp/terraform-provider-azuread/blob/main/docs/guides/service_principal_configuration.md
  https://github.com/hashicorp/terraform-provider-azuread/blob/main/docs/guides/microsoft-graph.md

  *** And - the Service Principle must have GA permissions in the Tenant
      https://docs.microsoft.com/en-us/azure/active-directory-domain-services/template-create-instance
      * You need global administrator privileges in your Azure AD tenant to enable Azure AD DS.
      * You need Contributor privileges in your Azure subscription to create the required Azure AD DS resources.

  Status:  In Progress

  Files in Module:
    aadds.main.tf
    aadds.vars.tf
    aadds.vars.tfvars

  Usage:
  terraform apply --auto-approve -var-file=".\aads.vars.tfvars"
  terraform destroy --auto-approve -var-file=".\aads.vars.tfvars"

  ToDo:
    * Create users/groups in advance - use existing AAD.
    * Put it in existing vnet/subnet reserved for AAD-DS (core/hub?)
    * Create Windows Server VM for mgmt host?  Or use an existing one.
 

*/

###===================================================================================###
#     Start creating infrastructure resources
###===================================================================================###

resource "azurerm_resource_group" "aadds-rg" {
  name     = "${var.prefix}-rg"
  location = "${var.region}"
}


###===================================================================================###
###    AAD DS Creation Section
###    https://docs.microsoft.com/en-us/azure/active-directory-domain-services/powershell-create-instance
###    https://docs.microsoft.com/en-us/azure/active-directory-domain-services/powershell-create-instance#create-required-azure-ad-resources
###===================================================================================###

###--- Need this SP to add the AAD DS, it is already created
data "azuread_service_principal" "aadds-sp" {
  application_id = var.domain_controller_services_id
}

###--- AAD Config
# Create an AD Group
resource "azuread_group" "dc_admins" {
  display_name     = "${var.aadds-group}"
  description      = "AADDS Administrators"
  security_enabled = true
}

resource "azuread_user" "admin" {
  user_principal_name = "${var.dcadmin_upn}"
  display_name        = "${var.display_name}"
  password            = "${var.password}"
}

# Add the DC Admin user to the Admin group
resource "azuread_group_member" "admin" {
  group_object_id  = azuread_group.dc_admins.object_id
  member_object_id = azuread_user.admin.object_id
}

###--- Create the AAD DS
resource "azurerm_active_directory_domain_service" "aadds-dom" {
  location              = azurerm_resource_group.aadds-rg.location
  resource_group_name   = azurerm_resource_group.aadds-rg.name

  name                  = "${var.aadds_name}"
  domain_name           = "${var.domain_name}"
  sku                   = "${var.aadds_sku}"
  filtered_sync_enabled = true

  initial_replica_set {
    subnet_id = azurerm_subnet.aadds-subnet["default"].id
  }

  notifications {
    notify_dc_admins        = true
    notify_global_admins    = false
  }

  # TBD - For password sync - need a cert.
  #secure_ldap {
  #  enabled = true
  #}

  security {
    sync_kerberos_passwords = true
    sync_ntlm_passwords     = true
    sync_on_prem_passwords  = true
  }

  tags = {
    Environment = "prod"
  }

###--- Need this?  "depends_on" is deprecated
#  depends_on = [
#    azuread_service_principal.pshell-sp,
#    azurerm_subnet_network_security_group_association.nsg-map,
#  ]
}