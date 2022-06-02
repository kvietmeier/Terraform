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


resource "azurerm_resource_group" "aks-demo" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_kubernetes_cluster" "akscluster" {
  name                = var.aks_name
  location            = azurerm_resource_group.aks-demo.location
  resource_group_name = azurerm_resource_group.aks-demo.name
  dns_prefix          = var.prefix

  kubernetes_version = var.kubernetes_version

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = var.vm_size
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

  tags = {
    Project = "AKS_Testing"
  }

  role_based_access_control {
    enabled = false
  }
}