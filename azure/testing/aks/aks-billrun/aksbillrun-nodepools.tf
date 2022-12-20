###===================================================================================###
#   Copyright (C) 2022 Intel Corporation
#   SPDX-License-Identifier: Apache-2.0
###===================================================================================###
#
#  File:  aks2-nodepools.tf
#  Created By: Karl Vietmeier
#
#  Purpose:  Create additional nodepools for the cluster
# 
###===================================================================================###

/* 

  Put Usage Documentation here
  
  Reference Docs - 
   https://docs.microsoft.com/en-us/azure/aks/custom-node-configuration
   https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool
   https://blog.wimwauters.com/devops/2022-03-01_terraformusecases/

*/


###===================================================================================###
###   Configure additional node pools
###===================================================================================###
resource azurerm_kubernetes_cluster_node_pool "cpu_manager" {
  
  for_each = { for each in var.nodepools : each.name => each }
  
  # Set for each nodepool
  name        = each.value.name
  node_count  = each.value.node_count
  vm_size     = each.value.vm_size
  
  # Set for all nodepools the same
  kubernetes_cluster_id        = azurerm_kubernetes_cluster.k8s.id
  proximity_placement_group_id = azurerm_proximity_placement_group.aks_prox_grp.id
  orchestrator_version         = var.orchestrator_version
  os_sku                       = var.os_sku
  os_disk_size_gb              = var.os_disk_size_gb
  

  /* 
    Run some "az" and kubectl commands using "local-exec" Doing it here so it goes at the end of the run
     https://developer.hashicorp.com/terraform/language/resources/provisioners/syntax
     https://www.terraform.io/language/resources/provisioners/local-exec
  */

  provisioner "local-exec" {
    # Get the cluster config for kubectl
    command = "az aks get-credentials --resource-group ${azurerm_resource_group.aks-rg.name} --name ${azurerm_kubernetes_cluster.k8s.name} --overwrite-existing"
    on_failure = continue
  }

} ### End nodepool setup