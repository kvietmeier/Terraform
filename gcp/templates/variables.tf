###===================================================================================###
#
#  File:  variables.tf
#  Created By: Karl Vietmeier
#
#  Variable definitions with defaults
#
###===================================================================================###

variable "region" {
  description = "Region to deploy resources"
}

variable "zone" {
  description = "Availbility Zone"
}

variable "project_id" {
  description = "GCP Project ID"
}


###=================  Examples of complex variables: =================###

###---  Storage Account Info
# Using type = list(object({}))
# Usage:  for_each = { for each in var.storage_account_configs : each.name => each }
# Referencing: storage_account_name = azurerm_storage_account.storage_acct["files"].name

variable "storage_account_configs" {
  description = "Storage Account Definition"
  type = list(
    object(
      { name         = string,
        acct_kind    = string,
        account_tier = string,
        access_temp  = string,
        replication  = string
      }
    )
  )
}

###--- Fileshares
# Using type = list(object({}))
variable "shares" {
  description = "List of shares to create and their quotas."
  type = list(
    object(
      { name = string,
        quota = number 
      }
    )
  )
}


# Same thing but a list/map of multiple shares (simple key:value)
variable "file_shares" {
  description = "List of shares to create and their quotas."
  type        = map(any)
}

