output "ha_vpn_gateway_self_link" {
  value = google_compute_ha_vpn_gateway.ha_gateway.self_link
}

output "gcp_vpn_gateway_public_ips" {
  description = "Public IPs of the HA VPN gateway (feed to Azure peer)"
  value = [
    google_compute_ha_vpn_gateway.ha_gateway.vpn_interfaces[0].ip_address,
    google_compute_ha_vpn_gateway.ha_gateway.vpn_interfaces[1].ip_address
  ]
}

output "gcp_asn" {
  value = google_compute_router.router.bgp[0].asn
}

output "vpn_config_for_azure" {
  value = {
    ip_0 = google_compute_ha_vpn_gateway.ha_gateway.vpn_interfaces[0].ip_address
    ip_1 = google_compute_ha_vpn_gateway.ha_gateway.vpn_interfaces[1].ip_address
    asn  = google_compute_router.router.bgp[0].asn
  }
}

output "vpn_tunnel0_id" {
  value = google_compute_vpn_tunnel.tunnel0.id
}

output "vpn_tunnel1_id" {
  value = google_compute_vpn_tunnel.tunnel1.id
}
