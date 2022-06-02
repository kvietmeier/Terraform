###===================================================================================###
#   Copyright (C) 2022 Intel Corporation
#   SPDX-License-Identifier: Apache-2.0
###===================================================================================###
#
#  File:  variables.tf
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
#  Usage:
#  terraform apply --auto-approve
#  terraform destroy --auto-approve
###===================================================================================###


variable "resource_group_name" {
  description = "The Azure resource group for this AKS Cluster"
  default     = "AKS-Testing"
}

variable "aks_name" {
  description = "AKS Cluster name"
  default     = "TestCluster"
}

variable "prefix" {
  description = "A prefix to use for all resources in this AKS Cluster"
  default     = "akscluster"
}

variable "location" {
  description = "Azure Region where this AKS Cluster should be provisioned"
  default     = "West US 2"
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

variable "client_id" {
  description = "The Client ID for the Service Principal to use for this AKS Cluster"
}

variable "client_secret" {
  description = "The Client Secret for the Service Principal to use for this AKS Cluster"
}