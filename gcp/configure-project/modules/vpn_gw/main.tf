###===================================================================================###
#  Module: vpn_gw
#  Adapted from gcp/CoreInfra/vpn_gw (left untouched).
#  VIP advertise ranges are variables (were hardcoded in original).
###===================================================================================###

resource "google_compute_address" "vpn_static_ip_0" {
  name   = "vpn-static-ip-0"
  region = var.region
}

resource "google_compute_address" "vpn_static_ip_1" {
  name   = "vpn-static-ip-1"
  region = var.region
}

resource "google_compute_ha_vpn_gateway" "ha_gateway" {
  name    = var.ha_vpn_gw_name
  network = var.network
  region  = var.region
}

resource "google_compute_router" "router" {
  name    = var.router_name
  network = var.network
  region  = var.region

  bgp {
    asn               = var.gcp_asn
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]

    dynamic "advertised_ip_ranges" {
      for_each = var.advertised_ip_ranges
      content {
        range       = advertised_ip_ranges.value.range
        description = advertised_ip_ranges.value.description
      }
    }
  }
}

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

resource "google_compute_router_interface" "router_interface0" {
  name       = var.interface0
  router     = google_compute_router.router.name
  region     = var.region
  ip_range   = "${var.gcp_apipa_bgp_a}/30"
  vpn_tunnel = google_compute_vpn_tunnel.tunnel0.name
}

resource "google_compute_router_interface" "router_interface1" {
  name       = var.interface1
  router     = google_compute_router.router.name
  region     = var.region
  ip_range   = "${var.gcp_apipa_bgp_b}/30"
  vpn_tunnel = google_compute_vpn_tunnel.tunnel1.name
}

resource "google_compute_router_peer" "bgp_peer0" {
  name                      = var.bgp_peer_if0
  router                    = google_compute_router.router.name
  region                    = var.region
  peer_ip_address           = var.azure_apipa_bgp_a
  peer_asn                  = var.azure_asn
  advertised_route_priority = var.priority
  interface                 = google_compute_router_interface.router_interface0.name
}

resource "google_compute_router_peer" "bgp_peer1" {
  name                      = var.bgp_peer_if1
  router                    = google_compute_router.router.name
  region                    = var.region
  peer_ip_address           = var.azure_apipa_bgp_b
  peer_asn                  = var.azure_asn
  advertised_route_priority = var.priority
  interface                 = google_compute_router_interface.router_interface1.name
}
