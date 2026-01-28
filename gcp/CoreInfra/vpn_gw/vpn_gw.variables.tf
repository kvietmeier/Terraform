# variables.tf
#
# Copyright 2025 Karl Vietmeier
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# created by: Karl Vietmeier
variable "project_id" {
  type        = string
  description = "The GCP Project ID"
}

variable "region" {
  type        = string
  description = "GCP Region"
}

variable "zone" {
  description = "Availbility Zone"
}

variable "network" {
  type        = string
  description = "The VPC network name"
}

variable "ha_vpn_gw_name" {
  type        = string
  description = "Name of the HA VPN Gateway"
}

variable "router_name" {
  type        = string
  description = "Name of the Cloud Router"
}

variable "external_gw_name" {
  type        = string
  description = "Name of the External peer gateway"
}

variable "gcp_asn" {
  type        = string
  description = "BGP ASN for the GCP side"
}

variable "tunnel_if0" {
  type        = string
  description = "Name for VPN Tunnel 0"
}

variable "tunnel_if1" {
  type        = string
  description = "Name for VPN Tunnel 1"
}

variable "interface0" {
  type        = string
  description = "Name for Router Interface 0"
}

variable "interface1" {
  type        = string
  description = "Name for Router Interface 1"
}

variable "gcp_apipa_bgp_a" {
  type        = string
  description = "GCP BGP IP for Interface 0 (APIPA)"
}

variable "gcp_apipa_bgp_b" {
  type        = string
  description = "GCP BGP IP for Interface 1 (APIPA)"
}

variable "bgp_peer_if0" {
  type        = string
  description = "Name for BGP Peer 0"
}

variable "bgp_peer_if1" {
  type        = string
  description = "Name for BGP Peer 1"
}

variable "priority" {
  type        = number
  description = "BGP Route Priority"
}

variable "shared_key" {
  type        = string
  description = "IKEv2 Shared Secret"
  sensitive   = true
}

variable "azure_pubip0" {
  type        = string
  description = "Public IP of Azure Interface 0"
}

variable "azure_pubip1" {
  type        = string
  description = "Public IP of Azure Interface 1"
}

variable "azure_apipa_bgp_a" {
  type        = string
  description = "Azure BGP IP for Interface 0"
}

variable "azure_apipa_bgp_b" {
  type        = string
  description = "Azure BGP IP for Interface 1"
}

variable "azure_asn_b" {
  type        = string
  description = "Azure side BGP ASN"
}