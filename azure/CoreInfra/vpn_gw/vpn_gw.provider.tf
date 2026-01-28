###===================================================================================###
#
#  File:  provider.tf
#  Created By: Karl Vietmeier
#
#  Purpose: Configure Provider
# 
###===================================================================================###
# Configure the Microsoft Azure Provider TerraForm

terraform {
  required_version = ">= 1.9"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.16"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
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
