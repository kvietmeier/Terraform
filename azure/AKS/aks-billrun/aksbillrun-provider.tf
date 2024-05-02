###===================================================================================###
#   Copyright (C) 2022 Intel Corporation
#   SPDX-License-Identifier: Apache-2.0
###===================================================================================###
#
#  File:  aksbillrun-provider.tf
#  Created By: Karl Vietmeier
#
#  Purpose: Configure Provider
# 
###===================================================================================###

# Configure the Microsoft Azure Provider
terraform {
  required_version = ">=1.0"

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>3.36"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {
    # Skip checking for any Resources within the Resource Group and delete this using the Azure API directly
    #resource_group {
    #   prevent_deletion_if_contains_resources = false
    #  }
  }
}
