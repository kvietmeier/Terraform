###===================================================================================###
#  File:  main.tf
#  Created By: Karl Vietmeier
#
#  Terraform Template Code
#  Purpose: Create multiple VMs each with 2 NICs.
# 
#  Files in Module:
#    main.tf
#    variables.tf
#    variables.tfvars
#
#  Usage:
#  terraform apply --auto-approve -var-file=".\variables.tfvars"
#  terraform destroy --auto-approve -var-file=".\variables.tfvars"
###===================================================================================###

###===============================#===================================================###
###--- Configure the Azure Provider
###===================================================================================###
# Configure the Microsoft Azure Provider
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}

provider "azurerm" {
  features {}
}


###===================================================================================###
#     Start creating infrastructure resources
###===================================================================================###