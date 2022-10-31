###===================================================================================###
#   Copyright (C) 2022 Intel Corporation
#   SPDX-License-Identifier: Apache-2.0
###===================================================================================###
#
#  File:  variables.tf
#  Created By: Karl Vietmeier
#
#  Variable definitions with defaults
#
###===================================================================================###

###--- Basic Infra
variable "resource_group_name" {
  description = "Resource Group"
  default     = "TF-StorageTesting"
}

variable "region" {
  description = "Region to deploy resources"
  default     = "westus2"
}

variable "prefix" {
  description = "A prefix to use for all resources"
  default     = "tf-storage"
}

###---  Storage Account Info
variable "acct_kind" {
  description = "The type of storage account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2."
  default     = "FileStorage"
  type        = string
}

variable "account_tier" {
  description = "Defines the access tier for BlobStorage and StorageV2 accounts. Valid options are Standard or Premium."
  default     = "Premium"
  type        = string
}

variable "access_temp" {
  description = "Defines the access type for BlobStorage and StorageV2 accounts. Valid options are Hot or Cold."
  default     = "Hot"
  type        = string
}

variable "replication" {
  description = "Replication scheme"
  default     = "LRS"
  type        = string
}

###--- Share settings
variable "share_quota" {
  description = "Size of share in GB"
  default     = "250"
  type        = string
}

variable "share_name" {
  description = "Name of the Fileshare - lower case only"
  default     = "sharevol01"
  type        = string
}

# List/map of multiple shares (simple key:value)
variable "file_shares" {
  description = "List of shares to create and their quotas."
  type        = map
}

# Use Object syntax  (complex object)
variable "shares" {
  description = "List of shares to create and their quotas."
  type        = list(object({ name = string, quota = number }))
}
