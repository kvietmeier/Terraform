###===================================================================================###
#   Copyright (C) 2022 Intel Corporation
#   SPDX-License-Identifier: Apache-2.0
###===================================================================================###
#
#  File:  outputs.tf
#  Created By: Karl Vietmeier
#
#  Output cluster information
#
###===================================================================================###


output "aks_id" {
  value = azurerm_kubernetes_cluster.akscluster.id
}

output "aks_fqdn" {
  value = azurerm_kubernetes_cluster.akscluster.fqdn
}

output "aks_node_rg" {
  value = azurerm_kubernetes_cluster.akscluster.node_resource_group
}

# Need to explicitly declare the variable non-sensitive with "nonsensitive(var)"
output "kube_config" {
  value = nonsensitive(azurerm_kubernetes_cluster.akscluster.kube_config_raw)
  #sensitive = true
}

output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "client_key" {
    value = azurerm_kubernetes_cluster.k8s.kube_config.0.client_key
}

output "client_certificate" {
    value = azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate
}

output "cluster_ca_certificate" {
    value = azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate
}

output "cluster_username" {
    value = azurerm_kubernetes_cluster.k8s.kube_config.0.username
}

output "cluster_password" {
    value = azurerm_kubernetes_cluster.k8s.kube_config.0.password
}

output "kube_config" {
    value = azurerm_kubernetes_cluster.k8s.kube_config_raw
    sensitive = true
}

output "host" {
    value = azurerm_kubernetes_cluster.k8s.kube_config.0.host
}