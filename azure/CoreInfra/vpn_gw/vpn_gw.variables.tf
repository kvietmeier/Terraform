###===================================================================================###
#
#  File:  variables.tf
#  Created By: Karl Vietmeier
#
#  Variable definitions with defaults
#
###===================================================================================###

variable "subscription_id" {
  type        = string
  description = "The Azure Subscription ID where resources will be deployed"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the Azure Resource Group"
}

variable "location" {
  type        = string
  description = "Azure Region (e.g., Central US)"
}

variable "vnet_name" {
  type        = string
  description = "Name of the Virtual Network"
}

variable "gateway_name" {
  type        = string
  description = "Name of the Azure Virtual Network Gateway"
}

variable "azure_asn" {
  type        = string
  description = "BGP ASN for the Azure side (e.g., 65010)"
}

variable "azure_apipa_bgp_a" {
  type        = string
  description = "Azure BGP Custom IP for Instance 0"
}

variable "azure_apipa_bgp_b" {
  type        = string
  description = "Azure BGP Custom IP for Instance 1"
}

variable "gcp_asn" {
  type        = string
  description = "BGP ASN for the GCP side (e.g., 65333)"
}

variable "gcp_apipa_bgp_a" {
  type        = string
  description = "GCP side BGP IP for Interface 0"
}

variable "gcp_apipa_bgp_b" {
  type        = string
  description = "GCP side BGP IP for Interface 1"
}

variable "gcp_pubip0" {
  type        = string
  description = "Public IP address of GCP HA Gateway Interface 0"
}

variable "gcp_pubip1" {
  type        = string
  description = "Public IP address of GCP HA Gateway Interface 1"
}

variable "shared_key" {
  type        = string
  description = "IKEv2 Shared Secret (Pre-shared key)"
  sensitive   = true
}