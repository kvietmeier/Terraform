####===================================================================================###
#   Copyright (C) 2022 Intel Corporation
#   SPDX-License-Identifier: Apache-2.0
###===================================================================================###
#
#  File:  azure_ad.variables.tf
#  Created By: Karl Vietmeier
#
#  Variable definitions with defaults
#
###===================================================================================###


variable "password" {
  description = "Default Password"
  default     = "foobbar"
}

variable "location" {
  description = "Region to deploy resources"
  default     = "westus2"
}

