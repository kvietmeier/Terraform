###===================================================================================###
#  Terraform Configuration File
#
#  Description : <Brief description of what this file does>
#  Author      : Karl Vietmeier
#
#  License     : Apache 2.0
#
###===================================================================================###


###===================================================================================###
#     Start creating infrastructure resources
###===================================================================================###

##############################
# Variables (replace as needed)
##############################
variable "project_id" {}
variable "region"     { default = "us-central1" }
variable "network"    { default = "vpc-hub" }

# Azure side public IPs for HA tunnels
variable "peer_ip_1"  { default = "4.249.107.59" }
variable "peer_ip_2"  { default = "4.249.107.48" }

##############################
# Cloud Router
##############################
resource "google_compute_router" "azure_router" {
  name    = "router-us-central1-azvpn"
  region  = var.region
  network = var.network

  bgp {
    asn               = 65333
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
  }
}

##############################
# HA VPN Gateway
##############################
resource "google_compute_ha_vpn_gateway" "ha_vpn" {
  name    = "vpngw-to-azure"
  region  = var.region
  network = var.network
}

##############################
# VPN Tunnels + BGP Peers
##############################

# Tunnel 1
resource "google_compute_vpn_tunnel" "vpn_tunnel_1" {
  name                  = "azure-central1-tunnel-if0"
  region                = var.region
  vpn_gateway           = google_compute_ha_vpn_gateway.ha_vpn.id
  vpn_gateway_interface = 0
  peer_ip               = var.peer_ip_1
  shared_secret         = "REPLACE_WITH_YOURS"

  router                = google_compute_router.azure_router.id
}

# Tunnel 2
resource "google_compute_vpn_tunnel" "vpn_tunnel_2" {
  name                  = "azure-central1-tunnel-if1"
  region                = var.region
  vpn_gateway           = google_compute_ha_vpn_gateway.ha_vpn.id
  vpn_gateway_interface = 1
  peer_ip               = var.peer_ip_2
  shared_secret         = "REPLACE_WITH_YOURS"

  router                = google_compute_router.azure_router.id
}

##############################
# BGP Peers (use priority=100!)
##############################

# BGP peer for Tunnel 1
resource "google_compute_router_bgp_peer" "peer_if0" {
  name                      = "azure-bgp-peer-if0"
  router                    = google_compute_router.azure_router.name
  region                    = var.region
  interface                  = google_compute_router_interface.if0.name
  peer_ip_address            = "169.254.21.10"
  peer_asn                   = 65515
  advertised_route_priority  = 100
}

# BGP peer for Tunnel 2
resource "google_compute_router_bgp_peer" "peer_if1" {
  name                      = "azure-bgp-peer-if1"
  router                    = google_compute_router.azure_router.name
  region                    = var.region
  interface                  = google_compute_router_interface.if1.name
  peer_ip_address            = "169.254.21.14"
  peer_asn                   = 65515
  advertised_route_priority  = 100
}

##############################
# Cloud Router Interfaces
##############################
resource "google_compute_router_interface" "if0" {
  name         = "interface-if0"
  router       = google_compute_router.azure_router.name
  region       = var.region
  ip_range     = "169.254.21.9/30"
  vpn_tunnel   = google_compute_vpn_tunnel.vpn_tunnel_1.name
}

resource "google_compute_router_interface" "if1" {
  name         = "interface-if1"
  router       = google_compute_router.azure_router.name
  region       = var.region
  ip_range     = "169.254.21.13/30"
  vpn_tunnel   = google_compute_vpn_tunnel.vpn_tunnel_2.name
}
