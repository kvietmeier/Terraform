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
 Following this example:
 https://docs.microsoft.com/en-us/azure/developer/terraform/create-k8s-cluster-with-tf-and-aks
 


 Put Usage Documentation here
 Notes:
 - Needed to enable host encryption
  az feature register --namespace "Microsoft.Compute" --name "EncryptionAtHost"

 - Enable kubectl to access this cluster -
  az login
  az aks get-credentials --resource-group AKS-Testing --name TestCluster  
  





*/


###===================================================================================###
#     Start creating infrastructure resources
###===================================================================================###


# We need a Resource Group to hold everything
resource "azurerm_resource_group" "aks-rg" {
  name     = var.resource_group_name
  location = var.region
}

# We need a vnet
module "network" {
  source              = "Azure/network/azurerm"
  resource_group_name = var.resource_group_name
  vnet_name           = "aks-vnet"
  address_space       = "10.52.0.0/16"
  subnet_prefixes     = ["10.52.0.0/24"]
  subnet_names        = ["subnet01"]
  depends_on          = [azurerm_resource_group.aks-rg]
}

###--- Setup the LAW
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_solution

resource "random_id" "log_analytics_workspace_name_suffix" {
    byte_length = 8
}

resource "azurerm_log_analytics_workspace" "akslaw" {
    # The WorkSpace name has to be unique across the whole of azure, not just the current subscription/tenant.
    name                = "${var.log_analytics_workspace_name}-${random_id.log_analytics_workspace_name_suffix.dec}"
    location            = azurerm_resource_group.aks-rg.location
    resource_group_name = azurerm_resource_group.aks-rg.name
    sku                 = var.log_analytics_workspace_sku
    retention_in_days   = var.log_retention_in_days
}

resource "azurerm_log_analytics_solution" "akslaw" {
    solution_name         = "ContainerInsights"
    resource_group_name   = azurerm_resource_group.aks-rg.name
    location              = azurerm_resource_group.aks-rg.location
    workspace_resource_id = azurerm_log_analytics_workspace.akslaw.id
    workspace_name        = azurerm_log_analytics_workspace.akslaw.name

    plan {
        publisher = "Microsoft"
        product   = "OMSGallery/ContainerInsights"
    }
} ###--- End LAW Setup


###===================================================================================###
###     AKS Cluster Definition 
###===================================================================================###

resource "azurerm_kubernetes_cluster" "k8s" {
  name                = var.cluster_name
  location            = azurerm_resource_group.aks-rg.location
  resource_group_name = azurerm_resource_group.aks-rg.name
  dns_prefix          = var.dns_prefix
  
  # Versions
  kubernetes_version  = var.kubernetes_version
  sku_tier            = var.sku_tier

  
  linux_profile {
    admin_username = var.admin_username

    ssh_key {
      #key_data = file(var.ssh_public_key)
      key_data = var.ssh_public_key
    }
  }

  default_node_pool {
    name                 = var.default_pool_name
    orchestrator_version = var.orchestrator_version
    node_count           = var.default_node_count
    vm_size              = var.vm_size
    /* 
    kubelet_config {
      cpu_manager_policy = var.cpu_manager_policy
    }
  
    linux_os_config {
      transparent_huge_page_enabled = var.transparent_huge_page_enabled
    } 
    */
  }

  service_principal {
    client_id     = var.aks_service_principal_app_id
    client_secret = var.aks_service_principal_client_secret
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.akslaw.id
  }

  ###--- Cluster network configuration
  network_profile {
    network_plugin     = var.network_plugin
    network_policy     = var.network_policy
    dns_service_ip     = var.net_profile_dns_service_ip
    outbound_type      = var.net_profile_outbound_type
    docker_bridge_cidr = var.net_profile_docker_bridge_cidr
    service_cidr       = var.net_profile_service_cidr
    #pod_cidr           = var.net_profile_pod_cidr
  }


  ###--- Misc
  tags = {
    Environment = "Development"
  }


} ### End Cluster definition


###===================================================================================###
###   Configure additional node pools
#  https://docs.microsoft.com/en-us/azure/aks/custom-node-configuration
#  https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool
###===================================================================================###
resource azurerm_kubernetes_cluster_node_pool "cpu_manager" {
  name                  = "cpumanager"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.k8s.id
  orchestrator_version  = var.orchestrator_version
  node_count            = var.node_count
  vm_size               = var.vm_size

  kubelet_config {
    cpu_manager_policy = var.cpu_manager_policy
  }
  
  linux_os_config {
    transparent_huge_page_enabled = var.transparent_huge_page_enabled
  }
  
  
}