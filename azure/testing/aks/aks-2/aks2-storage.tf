###===================================================================================###
#   Copyright (C) 2022 Intel Corporation
#   SPDX-License-Identifier: Apache-2.0
###===================================================================================###
#
#  File:  aks2-storage.tf
#  Created By: Karl Vietmeier
#
#  Terraform Module Code:
#  Purpose:  Create Azure File share/s
#
#   Terraform Docs -  
#   https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account
#   https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_share
#   https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_blob
#
###===================================================================================###

/* Put Usage Documentation here */

# Generate random text for a unique storage account name
resource "random_id" "randomID" {
  keepers = {
    # Generate a new ID only when a new resource group is defined - so we can re-use the ID.
    resource_group = azurerm_resource_group.aks-rg.name
  }

  byte_length = 6
}

# Create the Storage Account/s
resource "azurerm_storage_account" "storage_acct" {
  # Use for_each
  # In later references to the Storage Accounts you use the "name" of the key in the lookup
  # In this case - "files" and "blobs"
  for_each                 = { for each in var.storage_account_configs : each.name => each }
   
  # Example: storage_account_name = azurerm_storage_account.storage_acct["files"].name
   
  resource_group_name      = azurerm_resource_group.aks-rg.name
  location                 = azurerm_resource_group.aks-rg.location
  name                     = "${each.value.name}${random_id.randomID.dec}"
  account_kind             = each.value.acct_kind
  account_tier             = each.value.account_tier
  access_tier              = each.value.access_temp
  account_replication_type = each.value.replication
}

# Create shares using a complex object
resource "azurerm_storage_share" "fileshare" {
  #count = length(var.shares)
  for_each = { for each in var.shares: each.name => each }
    name     = each.value.name
    quota    = each.value.quota

    storage_account_name = azurerm_storage_account.storage_acct["files"].name
  
}

### TBD - create a blob containner

resource "azurerm_storage_container" "blobcontainer" {
  name                  = "appstore"
  storage_account_name = azurerm_storage_account.storage_acct["blobs"].name
  container_access_type = "blob"
}

### END main.tf


###==============================================================================================###
#              Scratch code for testing
###==============================================================================================###

/* Block Comnment
# Create shares using a simple map - Key:Value
resource "azurerm_storage_share" "shares" {
  storage_account_name = azurerm_storage_account.storage_acct.name
  for_each             = var.file_shares
  name                 = "${each.key}"
  quota                = "${each.value}"

} 
*/

# Do I need this?
/* 
resource "azurerm_storage_blob" "my_blob" {
  name                   = "blobshare"
  storage_container_name = azurerm_storage_container.blobcontainer.name
  storage_account_name   = azurerm_storage_account.storage_acct["blobs"].name
  type                   = "Block"
  access_tier            = "Hot"
  #source                 = "some-local-file.zip"
}

*/