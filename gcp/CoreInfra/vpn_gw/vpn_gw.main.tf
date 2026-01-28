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



# =========================================================================
# 1. HA VPN GATEWAY
# =========================================================================
resource "google_compute_ha_vpn_gateway" "ha_gateway" {
  name    = var.ha_vpn_gw_name
  network = var.network
  region  = var.region
}

# =========================================================================
# 2. CLOUD ROUTER
# =========================================================================
resource "google_compute_router" "router" {
  name    = var.router_name
  network = var.network
  region  = var.region
  
  bgp {
    asn = var.gcp_asn
  }
}

# =========================================================================
# 3. EXTERNAL VPN GATEWAY (Azure Side)
# =========================================================================
resource "google_compute_external_vpn_gateway" "external_gateway" {
  name            = var.external_gw_name
  redundancy_type = "TWO_IPS_REDUNDANCY"
  
  interface {
    id         = 0
    ip_address = var.azure_pubip0
  }
  
  interface {
    id         = 1
    ip_address = var.azure_pubip1
  }
}

# =========================================================================
# 4. VPN TUNNEL 0
# =========================================================================
resource "google_compute_vpn_tunnel" "tunnel0" {
  name                            = var.tunnel_if0
  region                          = var.region
  vpn_gateway                     = google_compute_ha_vpn_gateway.ha_gateway.id
  peer_external_gateway           = google_compute_external_vpn_gateway.external_gateway.id
  peer_external_gateway_interface = 0
  vpn_gateway_interface           = 0
  shared_secret                   = var.shared_key
  router                          = google_compute_router.router.id
  ike_version                     = 2
}

# =========================================================================
# 5. VPN TUNNEL 1
# =========================================================================
resource "google_compute_vpn_tunnel" "tunnel1" {
  name                            = var.tunnel_if1
  region                          = var.region
  vpn_gateway                     = google_compute_ha_vpn_gateway.ha_gateway.id
  peer_external_gateway           = google_compute_external_vpn_gateway.external_gateway.id
  peer_external_gateway_interface = 1
  vpn_gateway_interface           = 1
  shared_secret                   = var.shared_key
  router                          = google_compute_router.router.id
  ike_version                     = 2
}

# =========================================================================
# 6. ROUTER INTERFACE 0
# =========================================================================
resource "google_compute_router_interface" "router_interface0" {
  name       = var.interface0
  router     = google_compute_router.router.name
  region     = var.region
  ip_range   = "${var.gcp_apipa_bgp_a}/30"
  vpn_tunnel = google_compute_vpn_tunnel.tunnel0.name
}

# =========================================================================
# 7. ROUTER INTERFACE 1
# =========================================================================
resource "google_compute_router_interface" "router_interface1" {
  name       = var.interface1
  router     = google_compute_router.router.name
  region     = var.region
  # Note: Used gcp_apipa_bgp_b here (correction from original script)
  ip_range   = "${var.gcp_apipa_bgp_b}/30" 
  vpn_tunnel = google_compute_vpn_tunnel.tunnel1.name
}

# =========================================================================
# 8. BGP PEER 0
# =========================================================================
resource "google_compute_router_peer" "bgp_peer0" {
  name                      = var.bgp_peer_if0
  router                    = google_compute_router.router.name
  region                    = var.region
  peer_ip_address           = var.azure_apipa_bgp_a
  peer_asn                  = var.azure_asn_b
  advertised_route_priority = var.priority
  interface                 = google_compute_router_interface.router_interface0.name
}

# =========================================================================
# 9. BGP PEER 1
# =========================================================================
resource "google_compute_router_peer" "bgp_peer1" {
  name                      = var.bgp_peer_if1
  router                    = google_compute_router.router.name
  region                    = var.region
  peer_ip_address           = var.azure_apipa_bgp_b
  peer_asn                  = var.azure_asn_b
  advertised_route_priority = var.priority
  interface                 = google_compute_router_interface.router_interface1.name
}