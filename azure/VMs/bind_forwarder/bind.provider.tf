###===================================================================================###
#
#  File:  bind.provider.tf
#  Created By: Karl Vietmeier
#
#  Purpose: Tiny Ubuntu Azure VM BIND9 conditional forwarder for VAST DNS testing
#           when Azure Private DNS / custom DNS on the vNet cannot be updated.
#
#  Auth: az login / ARM_* env vars (see azure/README.md)
#
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
}
