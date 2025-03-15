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
      version = "~>3.0.0"
    }
  }
  #cloud {
  #  organization = "kcvconsulting"
  #  workspaces {
    # name = "coreinfra"
   # }
  #}
}

provider "azurerm" {
  skip_provider_registration = "true" 
  features {}
}