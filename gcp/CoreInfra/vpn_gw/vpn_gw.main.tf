# main.tf
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

/* The following GCP resources will be created/configured to establish the HA VPN with BGP:
  Resource Type,Terraform Resource Name,Function
  google_compute_ha_vpn_gateway,ha_vpn_gw,The GCP HA VPN Gateway (vpngw-to-azure) which has two interfaces with public IPs.
  google_compute_external_vpn_gateway,external_gw,Represents the Azure VPN Gateway (vpngw-azure) with its two public IPs.
  google_compute_router,cloud_router,The Cloud Router (router-us-centra1-azvpn) that handles dynamic BGP routing.
  google_compute_vpn_tunnel,"tunnel_0, tunnel_1","The two VPN Tunnels (azure-central1-tunnel-if0, if1) connecting the GCP and Azure gateways."
  google_compute_router_interface,"router_if_0, router_if_1",Defines the BGP interfaces on the Cloud Router with the GCP BGP link-local IPs.
  google_compute_router_peer,"bgp_peer_0, bgp_peer_1",Defines the BGP peers with the Azure ASN and Azure BGP link-local IPs.
*/

# Data source for the existing VPC network
data "google_compute_network" "vpc_network" {
  name = var.network_name
}

# --- 1. HA VPN Gateway ---
resource "google_compute_ha_vpn_gateway" "ha_vpn_gw" {
  name    = var.vpn_gateway_name
  network = data.google_compute_network.vpc_network.id
  region  = var.region
}

# --- 2. External VPN Gateway (Azure side) ---
resource "google_compute_external_vpn_gateway" "external_gw" {
  name            = var.external_gateway_name
  redundancy_type = "TWO_IPS_REDUNDANCY"

  # Interface 0
  interface {
    id         = 0
    ip_address = var.azure_peer_ip_0
  }

  # Interface 1
  interface {
    id         = 1
    ip_address = var.azure_peer_ip_1
  }
}

# --- 3. Cloud Router ---
resource "google_compute_router" "cloud_router" {
  name    = var.router_name
  network = data.google_compute_network.vpc_network.id
  region  = var.region

  bgp {
    asn = var.gcp_asn
  }
}

# --- 4. VPN Tunnels ---
# VPN Tunnel 0
resource "google_compute_vpn_tunnel" "tunnel_0" {
  name                          = "azure-central1-tunnel-if0"
  region                        = var.region
  ike_version                   = 2
  shared_secret                 = var.shared_secret
  router                        = google_compute_router.cloud_router.name
  vpn_gateway                   = google_compute_ha_vpn_gateway.ha_vpn_gw.name
  vpn_gateway_interface         = 0 
  peer_external_gateway         = google_compute_external_vpn_gateway.external_gw.name
  peer_external_gateway_interface = 0 
  
  local_traffic_selector = ["0.0.0.0/0"]
  remote_traffic_selector = ["0.0.0.0/0"]
}

# VPN Tunnel 1
resource "google_compute_vpn_tunnel" "tunnel_1" {
  name                          = "azure-central1-tunnel-if1"
  region                        = var.region
  ike_version                   = 2
  shared_secret                 = var.shared_secret
  router                        = google_compute_router.cloud_router.name
  vpn_gateway                   = google_compute_ha_vpn_gateway.ha_vpn_gw.name
  vpn_gateway_interface         = 1 
  peer_external_gateway         = google_compute_external_vpn_gateway.external_gw.name
  peer_external_gateway_interface = 1 
  
  local_traffic_selector = ["0.0.0.0/0"]
  remote_traffic_selector = ["0.0.0.0/0"]
}

# --- 5. Cloud Router BGP Interfaces and Peers ---

# Cloud Router Interface for Tunnel 0
resource "google_compute_router_interface" "router_if_0" {
  name       = "azure-tunnel-if0"
  router     = google_compute_router.cloud_router.name
  region     = var.region
  vpn_tunnel = google_compute_vpn_tunnel.tunnel_0.name
  ip_range   = var.gcp_bgp_ip_0 
}

# Cloud Router BGP Peer for Tunnel 0
resource "google_compute_router_peer" "bgp_peer_0" {
  name                      = "azure-bgp-peer-if0"
  router                    = google_compute_router.cloud_router.name
  region                    = var.region
  peer_asn                  = var.azure_asn
  interface                 = google_compute_router_interface.router_if_0.name
  peer_ip_address           = var.azure_bgp_ip_0
  advertised_route_priority = var.advertised_route_priority
  
  dynamic "advertised_ip_ranges" {
    for_each = var.advertised_ip_ranges
    content {
      range = advertised_ip_ranges.value
    }
  }
}

# Cloud Router Interface for Tunnel 1
resource "google_compute_router_interface" "router_if_1" {
  name       = "azure-tunnel-if1"
  router     = google_compute_router.cloud_router.name
  region     = var.region
  vpn_tunnel = google_compute_vpn_tunnel.tunnel_1.name
  ip_range   = var.gcp_bgp_ip_1
}

# Cloud Router BGP Peer for Tunnel 1
resource "google_compute_router_peer" "bgp_peer_1" {
  name                      = "azure-bgp-peer-if1"
  router                    = google_compute_router.cloud_router.name
  region                    = var.region
  peer_asn                  = var.azure_asn
  interface                 = google_compute_router_interface.router_if_1.name
  peer_ip_address           = var.azure_bgp_ip_1
  advertised_route_priority = var.advertised_route_priority
  
  dynamic "advertised_ip_ranges" {
    for_each = var.advertised_ip_ranges
    content {
      range = advertised_ip_ranges.value
    }
  }
}