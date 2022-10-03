###===================================================================================###
#   Copyright (C) 2022 Intel Corporation
#   SPDX-License-Identifier: Apache-2.0
###===================================================================================###
#
#  File:  variables.tf
#  Created By: Karl Vietmeier
#
###===================================================================================###

/* 

Put Usage information here

*/

###=============================  Basic Azure Infra  =================================###
variable "resource_group_name" {
  description = "The Azure resource group for this AKS Cluster"
  default     = "AKS-Testing"
  type        = string
}

variable "region" {
  description = "Azure Region where this AKS Cluster should be provisioned"
  default     = "westus2"
  type        = string
}

variable "resource_group_location" {
  description = "Location of the resource group."
  default     = "westus2"
  type        = string
}

variable "resource_group_name_prefix" {
  description = "Prefix of the resource group name can be combined with a random ID so name is unique in your Azure subscription."
  default     = "rg"
  type        = string
}


###====================#=======   Cluster Configuration  =============================###
variable "dns_prefix" {
  default = "k8stest"
  type    = string
}

variable cluster_name {
  default = "k8stest"
  type    = string
}

variable "node_count" {
  description = "Number of Azure VMs in the node pool"
  default     = 1
  type        = number
}

variable "vm_size" {
  description = "VM size for the node pool"
  default     = "Standard_DS2_v2"
  type        = string
}

variable "admin_username" {
  default     = "aksadmin"
  description = "The username of the local administrator to be created on the Kubernetes cluster"
  type        = string
}


###================================== Network Config ==================================###
variable "network_plugin" {
  description = "Network plugin to use for networking."
  type        = string
  default     = "kubenet"
}

variable "network_policy" {
  description = "(Optional) Sets up network policy to be used with Azure CNI. Network policy allows us to control the traffic flow between pods. Currently supported values are calico and azure. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "net_profile_dns_service_ip" {
  description = "(Optional) IP address within the Kubernetes service address range that will be used by cluster service discovery (kube-dns). Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "net_profile_docker_bridge_cidr" {
  description = "(Optional) IP address (in CIDR notation) used as the Docker bridge IP address on nodes. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "net_profile_outbound_type" {
  description = "(Optional) The outbound (egress) routing method which should be used for this Kubernetes Cluster. Possible values are loadBalancer and userDefinedRouting. Defaults to loadBalancer."
  type        = string
  default     = "loadBalancer"
}

variable "net_profile_pod_cidr" {
  description = " (Optional) The CIDR to use for pod IP addresses. This field can only be set when network_plugin is set to kubenet. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "net_profile_service_cidr" {
  description = "(Optional) The Network Range used by the Kubernetes service. Changing this forces a new resource to be created."
  type        = string
  default     = null
}


###==================================   Law Setup    ==================================###
# Refer https://azure.microsoft.com/global-infrastructure/services/?products=monitor for log analytics available regions
# Refer to: https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing 
# Terraform values:" https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace

variable log_analytics_workspace_name {
  default = "AKSLAW-Name"
  type    = string
}

variable log_analytics_workspace_location {
  default = "westus2"
  type    = string
}

variable log_analytics_workspace_sku {
  default = "PerGB2018"
  type    = string
}

variable "log_retention_in_days" {
  description = "The retention period for the logs in days"
  type        = number
  default     = 30
}


###==============================  Secrets - in tfvars  ===============================###
variable "client_id" {
  description = "The Client ID for the Service Principal to use for this AKS Cluster"
  type        = string
}

variable "client_secret" {
  description = "The Client Secret for the Service Principal to use for this AKS Cluster"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH Key for the cludster nodes"
  type        = string
}