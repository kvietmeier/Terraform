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
  description = "The GCP project ID where resources will be created"
  type        = string
}

variable "region" {
  description = "The GCP region for all resources"
  type        = string
  default     = "us-central1"
}

variable "network_name" {
  description = "The VPC network to attach the VPN to (e.g., karlv-corevpc)"
  type        = string
}


variable "vpn_gateway_name" {
  description = "Name for the GCP HA VPN Gateway"
  type        = string
  default     = "vpngw-to-azure"
}

variable "router_name" {
  description = "Name for the Cloud Router"
  type        = string
  default     = "router-us-centra1-azvpn" # Keeping the 'centra1' typo to match gcloud output for consistency
}

variable "external_gateway_name" {
  description = "Name for the External VPN Gateway (Azure peer)"
  type        = string
  default     = "vpngw-azure"
}


### GCP VPN Gateway Settings
variable "gcp_asn" {
  description = "The BGP ASN for the Cloud Router (GCP side)"
  type        = number
  default     = 65333
}

variable "gcp_bgp_ip_0" {
  description = "GCP BGP Peer IP (inside tunnel 0) - /30 IP"
  type        = string
  default     = "169.254.21.9/30"
}

variable "gcp_bgp_ip_1" {
  description = "GCP BGP Peer IP (inside tunnel 1) - /30 IP"
  type        = string
  default     = "169.254.21.13/30"
}

variable "advertised_ip_ranges" {
  description = "List of CIDRs to advertise via BGP. If empty, all subnets in the VPC will be advertised (DEFAULT mode)."
  type        = list(string)
  default     = [] # Using default mode, but you could specify ranges for 'CUSTOM' mode
}

variable "advertised_route_priority" {
  description = "Priority of routes advertised to the BGP peer"
  type        = number
  default     = 100
}

variable "shared_secret" {
  description = "The pre-shared key for the VPN tunnels"
  type        = string
  sensitive   = true
}


### Azure VPN Gateway Settings
variable "azure_asn" {
  description = "The BGP ASN for the Azure VPN Gateway (Peer side)"
  type        = number
  # Note: The gcloud commands used 65005, but the 'Data' section mentioned 65515. 
  # Using 65005 to match the peer configuration commands.
  default     = 65005 
}

variable "azure_peer_ip_0" {
  description = "Azure VPN Gateway Public IP #1 (for GCP Interface 0)"
  type        = string
}

variable "azure_peer_ip_1" {
  description = "Azure VPN Gateway Public IP #2 (for GCP Interface 1)"
  type        = string
}

variable "azure_bgp_ip_0" {
  description = "Azure BGP Peer IP (inside tunnel 0)"
  type        = string
}

variable "azure_bgp_ip_1" {
  description = "Azure BGP Peer IP (inside tunnel 1)"
  type        = string
}
