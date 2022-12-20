###===================================================================================###
#   Copyright (C) 2022 Intel Corporation
#   SPDX-License-Identifier: Apache-2.0
###===================================================================================###
#
#  File:  aks2-storagre-variables.tf
#  Created By: Karl Vietmeier
#
#  Storage related variable definitions
#
###===================================================================================###

###---  Storage Account Info
# Using type = list(object({}))
variable "storage_account_configs" {
  description = "Resource Group"
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

