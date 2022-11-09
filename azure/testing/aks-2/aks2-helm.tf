###===================================================================================###
#   Copyright (C) 2022 Intel Corporation
#   SPDX-License-Identifier: Apache-2.0
###===================================================================================###
#
#  File:  aks2-helm.tf
#  Created By: Karl Vietmeier
#
#  Terraform Module Code
#  Purpose:  Configure Helm for an AKS cluster
# 
###===================================================================================###

/* 

Put Usage Documentation here

*/


###===================================================================================###
#     Start creating resources
###===================================================================================###


# Cluster info
data "azurerm_kubernetes_cluster" "credentials" {
  name                = azurerm_kubernetes_cluster.k8s.name
  resource_group_name = azurerm_resource_group.aks-rg.name
}

# Enable Helm
provider "helm" {
  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.credentials.kube_config.0.host
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.credentials.kube_config.0.client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.credentials.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.credentials.kube_config.0.cluster_ca_certificate)

  }
}

###----- Helm Charts
resource "helm_release" "cilium_cni" {
  name       = "cilium"
  namespace  = "kube-system"
  repository = "https://helm.cilium.io/"
  chart      = "cilium"
  version    ="1.12.3"

  set {
    name  = "aksbyocni.enabled"
    value = "true"
  }
  
  set {
    name  = "nodeinit.enabled"
    value = "true"
  }

  depends_on = [ azurerm_kubernetes_cluster.k8s ]
}
