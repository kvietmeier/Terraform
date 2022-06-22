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

output "kube_config" {
  value = azurerm_kubernetes_cluster.akscluster.kube_config_raw
}