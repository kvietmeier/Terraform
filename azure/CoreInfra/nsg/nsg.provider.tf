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
###===================================================================================###

# Configure the Microsoft Azure Provider
terraform {
  required_version = ">=1.4"

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
  cloud {
    organization = "kcvconsulting"
    workspaces {
      name = "coreinfra"
    }
  }
}

provider "azurerm" {
  features {}
}

