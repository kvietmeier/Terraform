###===================================================================================###
#   Copyright (C) 2022 Intel Corporation
#   SPDX-License-Identifier: Apache-2.0
###===================================================================================###
#
#  File:  storagevolumes.tf
#  Created By: Karl Vietmeier
#
#  Terraform Module Code
#  Purpose:  Create Azure File share/s
#
#   Terraform Docs -  
#   https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account
#   https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_share
#   https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_blob
#
###===================================================================================###

/* Put Usage Documentation here */

# Always need this - 
resource "azurerm_resource_group" "storage-rg" {
  name     = var.resource_group_name
  location = var.region
}

# Generate random text for a unique storage account name
resource "random_id" "randomID" {
  keepers = {
    # Generate a new ID only when a new resource group is defined - so we can re-use the ID.
    resource_group = azurerm_resource_group.storage-rg.name
  }

  byte_length = 6
}

# Create the Storage Account
resource "azurerm_storage_account" "storage_acct" {
  name                     = "storacct${random_id.randomID.dec}"
  location                 = azurerm_resource_group.storage-rg.location
  resource_group_name      = azurerm_resource_group.storage-rg.name
  account_kind             = var.acct_kind
  account_tier             = var.account_tier
  access_tier              = var.access_temp
  account_replication_type = var.replication
}

# Create shares using a complex object
resource "azurerm_storage_share" "shares_obj" {
  storage_account_name = azurerm_storage_account.storage_acct.name
  count   = length(var.shares)
    
  name                 = var.shares[count.index].name
  quota                = var.shares[count.index].quota

  /*  Don't really need this?
  acl {
    id = "MTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTI"

    access_policy {
      permissions = "rwdl"
      start       = "2022-10-02T09:38:21.0000000Z"
      expiry      = "2025-07-02T10:38:21.0000000Z"
    }
  } */
}


/* # Create shares using a simple map - Key:Value
resource "azurerm_storage_share" "shares" {
  storage_account_name = azurerm_storage_account.storage_acct.name
  for_each             = var.file_shares
  name                 = "${each.key}"
  quota                = "${each.value}"

} */