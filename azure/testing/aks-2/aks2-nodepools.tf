###===================================================================================###
#   Copyright (C) 2022 Intel Corporation
#   SPDX-License-Identifier: Apache-2.0
###===================================================================================###
#
#  File:  submodule.tf
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
###===================================================================================###
resource azurerm_kubernetes_cluster_node_pool "cpu_manager" {
  # Should probably make these variables
  name                  = "cpumanager"

  # ID of cluster to add nodepool to
  kubernetes_cluster_id = azurerm_kubernetes_cluster.k8s.id
  
  # Set in *.tfvars
  orchestrator_version  = var.orchestrator_version
  node_count            = var.node_count
  vm_size               = var.vm_size

  ###--- Customize the nodepool
  
  # Need to add some metadata about capabilities
  #---- This needs to be a list variable
  node_labels           = {
    "iac-tool/node_profile"                  = "compute_intensive"
    "iac-tool/kubelet_cpu_manager_policy"    = "static"
    "iac-tool/tf_kubelet_cpu_manager_policy" = "user_data"  # tf_config
  }
  
  # Configure kubelet properties
  kubelet_config {
    cpu_manager_policy       = var.cpu_manager_policy
    topology_manager_policy  = var.topology_manager_policy
  }
  
  # Linux OS config
  linux_os_config {
    transparent_huge_page_enabled = var.transparent_huge_page_enabled
    transparent_huge_page_defrag  = var.transparent_huge_page_defrag

    # Add some sysctl config parameters
    sysctl_config {
      fs_file_max = var.fs_file_max
    }
  }

  /* 
    Run some "az" and kubectl commands using "local-exec" Doing it here so it goes at the end opf the run
     https://developer.hashicorp.com/terraform/language/resources/provisioners/syntax
     https://www.terraform.io/language/resources/provisioners/local-exec
  */

  provisioner "local-exec" {
    # Make sure we are logged in to the Tenant
    command = "az login --service-principal --username $aks_service_principal_app_id --password $aks_service_principal_client_secret --tenant $aks_tenant_id"
    on_failure = continue
  }
  
  provisioner "local-exec" {
    # Get the cluster config for kubectl
    command = "az aks get-credentials --resource-group AKS-Testing2 --name TestCluster2"
    on_failure = continue
  }

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

} ### End nodepool setup




###----  END Main 