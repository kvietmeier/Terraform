###===================================================================================###
#   Copyright (C) 2022 Intel Corporation
#   SPDX-License-Identifier: Apache-2.0
###===================================================================================###
#
#  File:  main.tf
#  Created By: Karl Vietmeier
#
#  Terraform Module Code
#  Purpose: Create an AKS cluster
# 
#  Files in Module:
#    main.tf
#    variables.tf
#    terraform.tfvars
#
#  Usage:
#  terraform apply --auto-approve
#  terraform destroy --auto-approve
###===================================================================================###

/* 

Put Usage Documentation here

*/


###===================================================================================###
#     Start creating infrastructure resources
###===================================================================================###


# We need a Resource Group to hold everything
resource "azurerm_resource_group" "aks-demo" {
  name     = var.resource_group_name
  location = var.location
}

# Define the AKS Cluster
resource "azurerm_kubernetes_cluster" "akscluster" {
  location            = azurerm_resource_group.aks-demo.location
  resource_group_name = azurerm_resource_group.aks-demo.name
  
  # Cluster arguments
  name                = var.aks_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version

  ###--- Argument blocks  
  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = var.vm_size
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

  role_based_access_control {
    enabled = false
  }
  
  tags = {
    Project = "AKS_Testing"
  }


}  ###---- End Cluster Definition ----###
