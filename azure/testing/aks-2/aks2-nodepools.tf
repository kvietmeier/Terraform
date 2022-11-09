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

*/


###===================================================================================###
###   Configure additional node pools
#  https://docs.microsoft.com/en-us/azure/aks/custom-node-configuration
#  https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool
#  https://blog.wimwauters.com/devops/2022-03-01_terraformusecases/
###===================================================================================###
resource azurerm_kubernetes_cluster_node_pool "cpu_manager" {
  
  for_each = { for each in var.nodepools : each.name => each }
  
  name = each.value.name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.k8s.id
  
  # Put this in the list so some nodepools are in some out?
  #count = each.value.proximity_placement_group ? 1 : 0
  
  proximity_placement_group_id = azurerm_proximity_placement_group.aks_prox_grp.id
  
  # Set in *.tfvars
  orchestrator_version  = var.orchestrator_version
  node_count            = each.value.node_count
  vm_size               = each.value.vm_size

  ###--- Customize the nodepool
  # Need to add some metadata about capabilities
  #---- <This needs to be a list variable>
  node_labels = {
    "iac-tool/node_profile"                  = "compute_intensive"
    "iac-tool/kubelet_cpu_manager_policy"    = "static"
    "iac-tool/tf_kubelet_cpu_manager_policy" = "user_data"  # tf_config
  }
  
  # Configure kubelet properties
  kubelet_config {
    cpu_manager_policy            = each.value.cpu_manager_policy
    topology_manager_policy       = each.value.topology_manager_policy
  }
  
  # Linux OS config
  linux_os_config {
    transparent_huge_page_enabled = each.value.transparent_huge_page_enabled
    transparent_huge_page_defrag  = each.value.transparent_huge_page_defrag

    # Add some sysctl config parameters
    sysctl_config {
      fs_file_max = each.value.fs_file_max
    }
  }

  /* 
    Run some "az" and kubectl commands using "local-exec" Doing it here so it goes at the end of the run
     https://developer.hashicorp.com/terraform/language/resources/provisioners/syntax
     https://www.terraform.io/language/resources/provisioners/local-exec
  */

  /* 
  provisioner "local-exec" {
    # Make sure we are logged in to the Tenant
    command = "az login --service-principal --username $aks_service_principal_app_id --password $aks_service_principal_client_secret --tenant $aks_tenant_id"
    on_failure = continue
  }

  */
  provisioner "local-exec" {
    # Get the cluster config for kubectl
    command = "az aks get-credentials --resource-group ${azurerm_resource_group.aks-rg.name} --name ${azurerm_kubernetes_cluster.k8s.name} --overwrite-existing"
    on_failure = continue
  }

  /*  
  provisioner "local-exec" {
    # Add cilium to ther Helm repo
    command = "helm repo add cilium https://helm.cilium.io/"
    on_failure = continue
  }
  
  provisioner "local-exec" {
    # Install cilium as the CNI plugin for network
    command = "helm install cilium cilium/cilium --version 1.12.3  --namespace kube-system  --set aksbyocni.enabled=true  --set nodeinit.enabled=true"
    on_failure = continue
  }
  */

} ### End nodepool setup