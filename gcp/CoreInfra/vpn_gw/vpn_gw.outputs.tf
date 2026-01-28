# outputs.tf
#
# Copyright 2025 Karl Vietmeier
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-20.0
#
# created by: Karl Vietmeier

output "ha_vpn_gateway_self_link" {
  description = "The URI of the created HA VPN Gateway"
  value       = google_compute_ha_vpn_gateway.ha_gateway.self_link
}

output "cloud_router_self_link" {
  description = "The URI of the created Cloud Router"
  value       = google_compute_router.router.self_link
}

output "external_gateway_self_link" {
  description = "The URI of the created External Peer Gateway"
  value       = google_compute_external_vpn_gateway.external_gateway.self_link
}

output "vpn_tunnel0_id" {
  description = "The ID of VPN Tunnel 0"
  value       = google_compute_vpn_tunnel.tunnel0.id
}

output "vpn_tunnel1_id" {
  description = "The ID of VPN Tunnel 1"
  value       = google_compute_vpn_tunnel.tunnel1.id
}

output "router_interface0_ip" {
  description = "The GCP side BGP IP for Interface 0"
  value       = google_compute_router_interface.router_interface0.ip_range
}

output "router_interface1_ip" {
  description = "The GCP side BGP IP for Interface 1"
  value       = google_compute_router_interface.router_interface1.ip_range
}