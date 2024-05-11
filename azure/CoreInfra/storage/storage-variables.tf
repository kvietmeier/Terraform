###===================================================================================###
#   Copyright (C) 2022 Intel Corporation
#   SPDX-License-Identifier: Apache-2.0
###===================================================================================###
#
#  File:  storage-variables.tf
#  Created By: Karl Vietmeier
#
#  Storage related variable definitions
#
###===================================================================================###



###=============================  Basic Azure Infra  =================================###
variable "resource_group_name" {
  description = "The Azure resource group for this AKS Cluster"
  default     = "StorageResources"
  type        = string
}

variable "region" {
  description = "Location of the resource group."
  default     = "westus2"
  type        = string
}

variable "resource_group_name_prefix" {
  description = "Prefix of the resource group name can be combined with a random ID so name is unique in your Azure subscription."
  default     = "rg"
  type        = string
}


###---  Storage Account Info
# Using type = list(object({}))
variable "storage_account_configs" {
  description = "Storage Account"
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

