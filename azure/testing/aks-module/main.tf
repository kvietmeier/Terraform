###===================================================================================###
#   Copyright (C) 2022 Intel Corporation
#   SPDX-License-Identifier: Apache-2.0
###===================================================================================###
#
#  File:  Template.tf
#  Created By: Karl Vietmeier
#
#  Purpose:  Create AKS Clusters
# 
#  Files in Module:
#    main.tf
#    variables.tf
#    variables.tfvars
#
#  Usage:
#  terraform apply --auto-approve
#  terraform destroy --auto-approve
###===================================================================================###

/* 
Provider information is in provider.tf

Notes:
- Needed to enable host encryption
  az feature register --namespace "Microsoft.Compute" --name "EncryptionAtHost"

- Enable kubectl to access this cluster -
  az aks get-credentials --resource-group aks-resource-group --name cpumgrtesting  

*/


###===================================================================================###
#     Start creating infrastructure resources
###===================================================================================###


# Create a Resource Group
resource "azurerm_resource_group" "aksrg" {
  name     = "aks-resource-group"
  location = "westus2"
}

# We need a vnet
module "network" {
  source              = "Azure/network/azurerm"
  resource_group_name = azurerm_resource_group.aksrg.name
  address_space       = "10.52.0.0/16"
  subnet_prefixes     = ["10.52.0.0/24"]
  subnet_names        = ["subnet01"]
  depends_on          = [azurerm_resource_group.aksrg]
}

# This needs to exist at this point (might add this in dynamically later)
data "azuread_group" "aks_cluster_admins" {
  display_name = "AKS-cluster-admins"
}

# Build the cluster
module "aks" {
  source                           = "Azure/aks/azurerm"
  resource_group_name              = azurerm_resource_group.aksrg.name
  prefix                           = "tf"

  # Service Principle for Auth and SSH Key - values stored in terraform.tfvars 
  client_id      = var.client_id
  client_secret  = var.client_secret
  public_ssh_key = var.public_ssh_key
  
  # Versions
  kubernetes_version               = "1.23.5"
  orchestrator_version             = "1.23.5"
  sku_tier                         = "Paid" # defaults to Free
  
  # Base Cluster configuration
  cluster_name                     = "cpumgrtesting"
  private_cluster_enabled          = false # default value
  enable_role_based_access_control = false
  rbac_aad_managed                 = false # AAD Auth deprecated in 1.25
  #rbac_aad_admin_group_object_ids  = [data.azuread_group.aks_cluster_admins.id]
  enable_azure_policy              = true
  enable_host_encryption           = false
  

  # Node Pool Configuration
  enable_auto_scaling              = true
  os_disk_size_gb                  = 100
  agents_size                      = "standard_d2ds_v5"
  agents_min_count                 = 1
  agents_max_count                 = 2
  agents_count                     = null # Please set `agents_count` `null` while `enable_auto_scaling` is `true` to avoid possible `agents_count` changes.
  agents_max_pods                  = 100
  agents_pool_name                 = "exnodepool"
  agents_availability_zones        = ["1", "2"]
  agents_type                      = "VirtualMachineScaleSets"

  agents_labels = {
    "nodepool" : "defaultnodepool"
  }

  agents_tags = {
    "Agent" : "defaultnodepoolagent"
  }

  ### Ingress/Approuting Setup
  enable_http_application_routing         = true
  
  # Enable AppGW setup (need an AppGW to exist) leage false for now.
  enable_ingress_application_gateway      = false
  ingress_application_gateway_name        = "aks-agw"
  ingress_application_gateway_subnet_cidr = "10.52.250.0/24"

  #### Internal K8S Network Setup
  vnet_subnet_id                 = module.network.vnet_subnets[0]
  network_plugin                 = "azure"
  network_policy                 = "azure"
  net_profile_dns_service_ip     = "10.40.0.10"
  net_profile_docker_bridge_cidr = "170.10.0.1/16"
  net_profile_service_cidr       = "10.40.0.0/16"
  depends_on                     = [module.network]


}  # END Module aks




