###===================================================================================###
#   Copyright (C) 2022 Intel Corporation
#   SPDX-License-Identifier: Apache-2.0
###===================================================================================###
#
#  File:  variables.tf
#  Created By: Karl Vietmeier
#
#  Variable definitions with defaults
#
###===================================================================================###

variable "kubernetes_version" {
  description = "K8S Version"
  default     = "1.23.5"
}

variable "orchestrator_version" {
  description = "Orchestrator Version"
  default     = "1.23.5"
}

variable "resource_group_name" {
  description = "Resource Group"
  default     = "TF-Testing"
}

variable "location" {
  description = "Region to deploy resources"
  default     = "westus2"
}

variable "prefix" {
  description = "A prefix to use for all resources"
  default     = "tf-testing"
}

variable "aks_name" {
  description = "AKS Cluster name"
  default     = "TestCluster"
}

variable "sku_tier" {
  description = "Cluster SKU"
  default     = "Paid"
}

variable "node_count" {
  description = "Number of Azure VMs in the node pool"
  default     = 1
}

variable "vm_size" {
  description = "VM size for the node pool"
  default     = "Standard_DS2_v5"
}





/* 

*/


# Sensitive variables
variable "public_ssh_key" {
  description = "A custom ssh key to control access to the AKS cluster"
  type        = string
  default     = ""
}

variable "client_id" {
  description = "The Client ID for the Service Principal to use for this AKS Cluster"
}

variable "client_secret" {
  description = "The Client Secret for the Service Principal to use for this AKS Cluster"
}