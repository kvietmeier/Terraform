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
  #name     = var.resource_group_name
  #location = var.region
  count    = length(var.resource_group_config)
  name     = var.resource_group_config[count.index].name
  location = var.resource_group_config[count.index].region
}

# Generate random text for a unique storage account name
resource "random_id" "randomID" {
  keepers = {
    # Generate a new ID only when a new resource group is defined - so we can re-use the ID.
    resource_group = azurerm_resource_group.storage-rg[0].name
  }

  byte_length = 6
}

# Create the Storage Account/s
resource "azurerm_storage_account" "storage_acct" {
  #count                    = length(var.storage_account_configs)

  # Use for_each
  for_each                 = { for each in var.storage_account_configs : each.name => each }
  location                 = var.resource_group_config[0].region
  name                     = "${each.value.name}${random_id.randomID.dec}"
  resource_group_name      = azurerm_resource_group.storage-rg[0].name
  account_kind             = each.value.acct_kind
  account_tier             = each.value.account_tier
  access_tier              = each.value.access_temp
  account_replication_type = each.value.replication
}

/* 
# Create shares using a complex object
resource "azurerm_storage_share" "fileshare" {
  #count = length(var.shares)
  for_each = { for each in var.shares: each.name => each }
  name     = each.value.name
  quota    = each.value.quota

  storage_account_name = azurerm_storage_account.storage_acct[each.key].name
  
}
*/
  
### END main.tf



###==============================================================================================###
#              Scratch code - trying to get it working
###==============================================================================================###

  /* 
  azurerm_storage_account.storage_acct[each.key]
  element(azurerm_storage_account.storage_acct[*].id, 0)
  element(azurerm_storage_account.storage_acct[*], 0)
  element(azurerm_storage_account.storage_acct[name], 0)
  azurerm_storage_account.storage_acct[0].name
  azurerm_storage_account.storage_acct.name
  storage_account_name = azurerm_storage_account.storage_acct.name
  storage_account_name = element(azurerm_storage_account.storage_acct[name], 0)
  storage_account_name = element(azurerm_storage_account.storage_acct[*], 0)
  storage_account_name = element(azurerm_storage_account.storage_acct[*].name, 0)
  storage_account_name = values(azurerm_storage_account.storage_acct[0]).name
  storage_account_name = azurerm_storage_account.storage_acct[0].name
  storage_account_name = azurerm_storage_account.storage_acct[]
  
  */

/* # Create shares using a simple map - Key:Value
resource "azurerm_storage_share" "shares" {
  storage_account_name = azurerm_storage_account.storage_acct.name
  for_each             = var.file_shares
  name                 = "${each.key}"
  quota                = "${each.value}"

} */