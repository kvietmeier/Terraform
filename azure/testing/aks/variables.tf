###===================================================================================###
#   Copyright (C) 2022 Intel Corporation
#   SPDX-License-Identifier: Apache-2.0
###===================================================================================###
#
#  File:  variables.tf
#  Created By: Karl Vietmeier
#
###===================================================================================###

### Basic infrastructure settings
variable "resource_group_name" {
  description = "The Azure resource group for this AKS Cluster"
  default     = "AKS-Testing"
}

variable "location" {
  description = "Azure Region where this AKS Cluster should be provisioned"
  default     = "West US 2"
}


### Cluster Variables
variable "dns_prefix" {
  description = "DNS prefix for the fqdn"
  default     = "akscluster"
}

variable "aks_name" {
  description = "AKS Cluster name"
  default     = "TestCluster"
}

variable "kubernetes_version" {
  description = "Kubernetes version deployed"
  default     = "1.23.5"
}

variable "node_count" {
  description = "Number of Azure VMs in the node pool"
  default     = 1
}

variable "vm_size" {
  description = "VM size for the node pool"
  default     = "Standard_DS2_v2"
}


### "Secrets"
variable "client_id" {
  description = "The Client ID for the Service Principal to use for this AKS Cluster"
}

variable "client_secret" {
  description = "The Client Secret for the Service Principal to use for this AKS Cluster"
}

variable "ssh_key" {
  description = "SSH Key for the cludster nodes"
}