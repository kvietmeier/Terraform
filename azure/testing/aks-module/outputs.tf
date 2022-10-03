###===================================================================================###
#   Copyright (C) 2022 Intel Corporation
#   SPDX-License-Identifier: Apache-2.0
###===================================================================================###
#
#  File:  outputs.tf
#  Created By: Karl Vietmeier
#
#  Purpose:  Output cluster info after apply
# 
###===================================================================================###


output "resource_group_name" {
  value = azurerm_resource_group.aksrg.name
}

output "kubernetes_cluster_name" {
  value     = module.aks
  sensitive = true
}

output "host" {
  #value = azurerm_kubernetes_cluster.main.kube_config.0.host
  #value = "${module.aks.kube_config_raw}"
  value = nonsensitive(module.aks.kube_config_raw)
  #sensitive = true
}

#output "client_key" {
#  value = azurerm_kubernetes_cluster.main.kube_config.0.client_key
#}

# output "client_certificate" {
#   value = azurerm_kubernetes_cluster.default.kube_config.0.client_certificate
# }

# output "kube_config" {
#   value = azurerm_kubernetes_cluster.default.kube_config_raw
# }

# output "cluster_username" {
#   value = azurerm_kubernetes_cluster.default.kube_config.0.username
# }

# output "cluster_password" {
#   value = azurerm_kubernetes_cluster.default.kube_config.0.password
# }
