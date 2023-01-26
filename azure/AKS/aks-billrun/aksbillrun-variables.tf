###===================================================================================###
#   Copyright (C) 2022 Intel Corporation
#   SPDX-License-Identifier: Apache-2.0
###===================================================================================###
#
#  File:  variables.tf
#  Created By: Karl Vietmeier
#
###===================================================================================###


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


###============================   Cluster Configuration  =============================###
variable cluster_name {
  default = "aks2-testing"
  type    = string
}

variable "dns_prefix" {
  default = "aks2"
  type    = string
}

variable "cluster_prefix" {
  default = "aks2"
  type    = string
}


variable "admin_username" {
  default     = "aksadmin"
  description = "The username of the local administrator to be created on the Kubernetes cluster"
  type        = string
}

variable "kubernetes_version" {
  default     = "1.24.6"
  description = "Version of Kubernetes"
  type        = string
}

variable "orchestrator_version" {
  default     = "1.24.6"
  description = "Version of Orchestrator"
  type        = string
}

variable "sku_tier" {
  default     = "Free"
  description = "AKS SKU"
  type        = string
}


###--- Default node pool
variable "default_pool_name" {
  description = "Name of the default node pool"
  default     = "defaultpool"
  type        = string
}

variable "default_node_count" {
  description = "Number of Azure VMs in the node pool"
  default     = 1
  type        = number
}

variable "default_vm_size" {
  description = "VM size for the node pool"
  default     = "Standard_DS2_v2"
  type        = string
}


###--- Default settings for additional node pools
variable "os_sku" {
  description = "Operating System"
  default     = "Ubuntu"
  type        = string
}

variable "os_disk_size_gb" {
  description = "OS Disk capacity/size"
  default     = "128"
  type        = number
}

variable "proximity_placement_group" {
  description = "VM size for the node pool"
  default     = "false"
  type        = bool
}


###===================================================================================###
# Nodepool configs  - use a complex object list for multiple nodepools
# Using type = list(object({}))
# Reference: for_each = { for each in var.nodepools : each.name => each }
###===================================================================================###
variable "nodepools" {
  description = "List of nodepools to create and the configuration for each."
  type = list(
    object(
      { 
        name                          = string,
        node_count                    = number,
        vm_size                       = string,
        os_sku                        = string
      }
    )
  )
} 



#- kubelet
variable "cpu_manager_policy" {
  description = "Pinning configuration (none or static)"
  default     = "static"
  type        = string
}

variable "topology_manager_policy" {
  description = "NUMA topology management - (none, best-effort, restricted, single-numa-node)"
  default     = "none"
  type        = string
}

#- Linux OS Config
variable "transparent_huge_page_enabled" {
  description = "Huge Pages Setup (always, madvise, never)"
  default     = "always"
  type        = string
}

variable "transparent_huge_page_defrag" {
  description = "Huge Pages defreag options (always, madvise, never, defer+madvise)"
  default     = "always"
  type        = string
}

variable "fs_file_max" {
  description = "sysctl: Must be between 8192-12000500"
  default     = "12000500"
  type        = string
}


###================================== Cluster Network Config ==================================###
variable "network_plugin" {
  description = "Network plugin to use for networking - azure, kubenet, or none"
  type        = string
  default     = "kubenet"
}

variable "network_policy" {
  # Sets up network policy to be used with Azure CNI. Network policy allows us to control the traffic 
  # flow between pods. Currently supported values are calico and azure.
  # NOTE - When network_policy is set to azure, the network_plugin field can only be set to azure.
  description = "(Optional)"
  type        = string
  default     = null
}

variable "net_profile_dns_service_ip" {
  # IP address within the Kubernetes service address range that will be used by 
  # cluster service discovery (kube-dns).
  description = "(Optional)"
  type        = string
  default     = null
}

variable "net_profile_docker_bridge_cidr" {
  # IP address (in CIDR notation) used as the Docker bridge IP address on nodes.
  description = "(Optional)"
  type        = string
  default     = null
}
 
variable "net_profile_outbound_type" {
  # The outbound (egress) routing method which should be used for this Kubernetes Cluster. 
  # Possible values are loadBalancer and userDefinedRouting. Defaults to loadBalancer."
  description = "(Optional)"
  type        = string
  default     = "loadBalancer"
}

variable "net_profile_pod_cidr" {
  # The CIDR to use for pod IP addresses. This field can only be set when 
  # network_plugin is set to kubenet.
  description = " (Optional)" 
  type        = string
  default     = null
}

variable "net_profile_service_cidr" {
  # The Network Range used by the Kubernetes service.
  description = "(Optional)"
  type        = string
  default     = null
}


###===================================================================================###
###                                     Law Setup                                     ###
# Refer https://azure.microsoft.com/global-infrastructure/services/?products=monitor for log analytics available regions
# Refer to: https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing 
# Terraform values:" https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace
###===================================================================================###

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


###===================================================================================###
###  Vnet Networking
###===================================================================================###

# vNet address spaces/cidrs
variable "vnet_cidr" {type = list(string)}

# Allow list for NSG
variable whitelist_ips {
  description = "A list of IP CIDR ranges to allow as clients. Do not use Azure tags like `Internet`."
  type        = list(string)
}

# Hub resources for vnet peering
variable "hub-rg" {type = string}
variable "hub-vnet" {type = string}

###--- subnets
# Using type = list(object({}))
variable "subnets" {
  description = "List of subnets to create and their address space."
  type = list(
    object(
      { name = string,
        cidr = string 
      }
    )
  )
}



###==============================  Secrets - in .tfvars ===============================###
variable "aks_service_principal_app_id" { 
  description = "The Client ID for the Service Principal to use for this AKS Cluster"
  type        = string
}

variable "aks_service_principal_client_secret" {
  description = "The Client Secret for the Service Principal to use for this AKS Cluster"
  type        = string
}

variable "aks_tenant_id" { 
  description = "The Client ID for the Service Principal to use for this AKS Cluster"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH Key for the cludster nodes"
  type        = string
}


###===================================================================================###
#   Retrieve existing resources in Azure
###===================================================================================###

### Right now we just need the Hub vNet to peer to.
# Resource Groups
data "azurerm_resource_group" "hub-rg" {
  name = "${var.hub-rg}"
}

# Hub vNet to peer to
data "azurerm_virtual_network" "hub-vnet" {
  resource_group_name = data.azurerm_resource_group.hub-rg.name
  name = "${var.hub-vnet}"
}

# Refer to them in maint.tf using: 
# data.azurerm_resource_group.hub-rg.name
# data.azurerm_resource_group.hub-rg.id
# data.azurerm_virtual_network.hub-vnet.name
# data.azurerm_virtual_network.hub-vnet.id


