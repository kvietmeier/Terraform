###===================================================================================###
# SUMMARY:
#   Terraform Provider Configuration for Azure.
#   Sets up the AzureRM provider and version constraints.
#   Relies on Azure CLI authentication (az login).
#
# USAGE:
#   Initialized automatically by 'terraform init'.
#
# LICENSE:
#   Copyright 2025 Karl Vietmeier / KCV Consulting
#   SPDX-License-Identifier: Apache-2.0
###===================================================================================###


terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  # Ensure you are in the right subscription!
  # Terraform will use your current CLI login (az login)
  # Run 'az account set --subscription "ID"' before running terraform
  #subscription_id = ""
}
