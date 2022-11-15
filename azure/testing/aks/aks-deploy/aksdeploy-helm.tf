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

  Might need this due to bug - 
  https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1234

  Windows:
  [Environment]::SetEnvironmentVariable("KUBE_CONFIG_PATH", "~/.kube/config")

  Comment - 
  "It appears to occur only when azurerm_kubernetes_cluster resource needs changes, 
   so terraform thinks that auth data is stale and ignores "kubernetes" block in
   helm's provider configuration and falls back to kubectl's config file"

*/


###===================================================================================###
#     Create Helm resources and add charts
###===================================================================================###


###----- Helm Charts
#- Install Cilium CNI plugin
resource "helm_release" "cilium_cni" {
  name       = "cilium"
  namespace  = "kube-system"
  repository = "https://helm.cilium.io/"
  chart      = "cilium"
  version    = "1.12.3"

  set {
    name  = "aksbyocni.enabled"
    value = "true"
  }
  
  set {
    name  = "nodeinit.enabled"
    value = "true"
  }

  set {
    name  = "global.kubeProxyReplacement"
    value = "strict"
  }

  #depends_on = [ azurerm_kubernetes_cluster.k8s ]
}

#- Node Feature Discovery
#helm install nfd/node-feature-discovery --set nameOverride=NFDinstance --set master.replicaCount=2 --namespace $NFD_NS --create-namespace
# 
# Doesn't work - namespace needs to already exist - could it go in kube-system?
# 
/* 
resource "helm_release" "nfd" {
  name       = "nodefeaturedisc"
  #namespace  = "node-feature-discovery"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/node-feature-discovery/charts"
  chart      = "node-feature-discovery"
  version    ="0.11.3"

  set {
    name  = "nameOverride"
    value = "NFDinstance"
  }
  
  set {
    name  = "master.replicaCount"
    value = "2"
  }
} 

 */