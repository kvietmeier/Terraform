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

variable "kubernetes_version" {
  description = "Kubernetes version deployed"
  default     = "1.18.14"
}

variable "node_count" {
  description = "Number of Azure VMs in the node pool"
  default     = 1
}

variable "vm_size" {
  description = "VM size for the node pool"
  default     = "Standard_DS2_v2"
}

# Sensitive variables
variable "client_id" {
  description = "The Client ID for the Service Principal to use for this AKS Cluster"
}

variable "client_secret" {
  description = "The Client Secret for the Service Principal to use for this AKS Cluster"
}