###===================================================================================###
#   Copyright (C) 2022 Intel Corporation
#   SPDX-License-Identifier: Apache-2.0
###===================================================================================###
#
#  File:  provider.tf
#  Created By: Karl Vietmeier
#
#  Purpose: Configure Providers
# 
###===================================================================================###

# Configure the Microsoft Azure Provider TerraForm
terraform {
  required_version = ">=1.3"

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
     azuread = {
      source  = "hashicorp/azuread"
      version = "2.0.1"
    }
  }
}

provider "azurerm" {
  features {}
}
