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
###===================================================================================###

/*
 Following this example:
 https://docs.microsoft.com/en-us/azure/developer/terraform/create-k8s-cluster-with-tf-and-aks
 
 Put Usage Documentation here
 Notes:
 - Needed to enable host encryption:
  az feature register --namespace "Microsoft.Compute" --name "EncryptionAtHost"

 - Enable kubectl to access this cluster:
  az login:
  az aks get-credentials --resource-group AKS-Testing --name TestCluster  

  In WSL2: 
  az aks get-credentials --resource-group AKS-Testing --name TestCluster --file ~/.kube/config --overwrite-existing
  
  PowerShell:
  Import-AzAksCredential -ResourceGroupName AKS-Testing -Name TestCluster

  - Create/destroy
  terraform apply --auto-approve -var-file=".\aks2-terraform.tfvars"
  terraform destroy --auto-approve -var-file=".\aks2-terraform.tfvars"

*/


###===================================================================================###
#     Create Infrastructure Resources
###===================================================================================###

# Need a Resource Group to hold everything
resource "azurerm_resource_group" "aks-rg" {
  name     = var.resource_group_name
  location = var.region
}

/* # Need a vnet
module "network" {
  source              = "Azure/network/azurerm"
  resource_group_name = var.resource_group_name
  vnet_name           = "aks-vnet"
  address_space       = "10.62.0.0/16"
  subnet_prefixes     = ["10.62.0.0/24"]
  subnet_names        = ["subnet01"]
  depends_on          = [azurerm_resource_group.aks-rg]
}
 */
 
# Create the vnet
resource "azurerm_virtual_network" "vnet" {
  resource_group_name   = azurerm_resource_group.aks-rg.name
  location              = azurerm_resource_group.aks-rg.location
  name                 = "${var.cluster_prefix}-vnet"
  address_space        = var.vnet_cidr
}

# Subnets 
resource "azurerm_subnet" "subnets" {
  resource_group_name   = azurerm_resource_group.aks-rg.name
  virtual_network_name  = azurerm_virtual_network.vnet.name
  
  # Create 2 subnets based on number of CIDRs defined in .tfvars
  # You can use this with simple key:value:
  # for_each = { for subnet in var.subnets : subnet.name => subnet.address_prefixes }

   for_each = { for each in var.subnets: each.name => each }
     name                 = each.value.name
     address_prefixes     = [each.value.cidr] 
}


# Create a Proximity Placement Group
resource "azurerm_proximity_placement_group" "aks_prox_grp" {
  resource_group_name   = azurerm_resource_group.aks-rg.name
  location              = azurerm_resource_group.aks-rg.location
  name                  = "AKSProximityPlacementGroup"
}


###===================================================================================###
#  Setup the LAW
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_solution
###===================================================================================###

resource "random_id" "log_analytics_workspace_name_suffix" {
    byte_length = 8
}

resource "azurerm_log_analytics_workspace" "akslaw" {
    # The WorkSpace name has to be unique across the whole of azure, not just the current subscription/tenant.
    name                = "${var.log_analytics_workspace_name}-${random_id.log_analytics_workspace_name_suffix.dec}"
    resource_group_name = azurerm_resource_group.aks-rg.name
    location            = azurerm_resource_group.aks-rg.location
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

  # In AKS/Terraform the "default" pool is the system pool - leave it basic and 
  # put customizations in an additonal pool (see below)
  default_node_pool {
    name                 = var.default_pool_name
    orchestrator_version = var.orchestrator_version
    node_count           = var.default_node_count
    vm_size              = var.vm_size
    
  } # end default nodepool

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
    #network_policy     = var.network_policy
    dns_service_ip     = var.net_profile_dns_service_ip
    outbound_type      = var.net_profile_outbound_type
    docker_bridge_cidr = var.net_profile_docker_bridge_cidr
    service_cidr       = var.net_profile_service_cidr
    pod_cidr           = var.net_profile_pod_cidr
  }

  ###--- Misc
  tags = {
    Environment = "Development"
  }
} ### End Cluster definition




#
### END main.tf
#



###===================================================================================###
#### Things to add:

### I don't like the module - 
/* 
# Create the vnet
resource "azurerm_virtual_network" "vnet" {
  location             = azurerm_resource_group.upf_rg.location
  resource_group_name  = azurerm_resource_group.upf_rg.name
  name                 = "${var.resource_prefix}-network"
  address_space        = var.vnet_cidr
}

# 2 Subnets - one for each NIC
resource "azurerm_subnet" "subnets" {
  resource_group_name  = azurerm_resource_group.upf_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  
  # Create 2 subnets based on number of CIDRs defined in .tfvars
  count                = length(var.subnet_cidrs)
  
  # Named "subnet01, subnet02" etc....  (keep number under 10)
  name                 = "subnet0${count.index}"
  
  # Using the address spaces in - subnet_cidrs
  address_prefixes     = [element(var.subnet_cidrs, count.index)]
}

*/