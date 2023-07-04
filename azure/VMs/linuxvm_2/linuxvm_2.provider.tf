###===================================================================================###
#   Copyright (C) 2022 Intel Corporation
#   SPDX-License-Identifier: Apache-2.0
###===================================================================================###
#
#  File:  provider.tf
#  Created By: Karl Vietmeier
#
#  Purpose: Configure Provider
#
#  Run "terraform init" when you make changes
# 
###===================================================================================###

# Configure the Microsoft Azure Provider TerraForm
terraform {
  required_version = ">=1.4"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.56"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {
   resource_group {
       # Go ahead and whack anything in the RG
       prevent_deletion_if_contains_resources = false
   }
  }
}
