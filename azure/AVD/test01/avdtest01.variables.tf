####===================================================================================###
#   Copyright (C) 2022 Intel Corporation
#   SPDX-License-Identifier: Apache-2.0
###===================================================================================###
#
#  File:  variables.tf
#  Created By: Karl Vietmeier
#
#  Variable definitions with defaults
#  
#  Copied from: https://learn.microsoft.com/en-us/azure/developer/terraform/configure-azure-virtual-desktop
#
###===================================================================================###


###===================================================================================###
###               Host Pool Vars                                                      ###
###===================================================================================###

variable "resource_group_location" {
default     = "eastus"
description = "Location of the resource group."
}

variable "rg_name" {
type        = string
default     = "rg-avd-resources"
description = "Name of the Resource group in which to deploy service objects"
}

variable "workspace" {
type        = string
description = "Name of the Azure Virtual Desktop workspace"
default     = "AVD TF Workspace"
}

variable "hostpool" {
type        = string
description = "Name of the Azure Virtual Desktop host pool"
default     = "AVD-TF-HP"
}

variable "rfc3339" {
type        = string
default     = "2022-03-30T12:43:13Z"
description = "Registration token expiration"
}

variable "prefix" {
type        = string
default     = "avdtf"
description = "Prefix of the name of the AVD machine(s)"
}

# Sensitive variables
variable "client_id" {
  description = "The Client ID for the Service Principal to use for this AKS Cluster"
}

variable "client_secret" {
  description = "The Client Secret for the Service Principal to use for this AKS Cluster"
}

###===================================================================================###
###               Session Host Vars                                                   ###
###===================================================================================###

variable "resource_group_location" {
  default     = "eastus"
  description = "Location of the resource group."
}

variable "rg" {
  type        = string
  default     = "rg-avd-compute"
  description = "Name of the Resource group in which to deploy session host"
}

variable "rdsh_count" {
  description = "Number of AVD machines to deploy"
  default     = 2
}

variable "prefix" {
  type        = string
  default     = "avdtf"
  description = "Prefix of the name of the AVD machine(s)"
}

variable "domain_name" {
  type        = string
  default     = "infra.local"
  description = "Name of the domain to join"
}

variable "domain_user_upn" {
  type        = string
  default     = "domainjoineruser" # do not include domain name as this is appended
  description = "Username for domain join (do not include domain name as this is appended)"
}

variable "domain_password" {
  type        = string
  default     = "ChangeMe123!"
  description = "Password of the user to authenticate with the domain"
  sensitive   = true
}

variable "vm_size" {
  description = "Size of the machine to deploy"
  default     = "Standard_DS2_v2"
}

variable "ou_path" {
  default = ""
}

variable "local_admin_username" {
  type        = string
  default     = "localadm"
  description = "local admin username"
}

variable "local_admin_password" {
  type        = string
  default     = "ChangeMe123!"
  description = "local admin password"
  sensitive   = true
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

