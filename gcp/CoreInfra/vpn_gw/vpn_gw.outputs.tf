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

# Output the public IP of the GCP HA VPN Gateway Interface 0
output "gcp_vpn_ip_0" {
  description = "Public IP address of the HA VPN Gateway Interface 0 (for Tunnel 1 to Azure)"
  value       = google_compute_ha_vpn_gateway.ha_vpn_gw.vpn_interfaces[0].ip_address
}

# Output the public IP of the GCP HA VPN Gateway Interface 1
output "gcp_vpn_ip_1" {
  description = "Public IP address of the HA VPN Gateway Interface 1 (for Tunnel 2 to Azure)"
  value       = google_compute_ha_vpn_gateway.ha_vpn_gw.vpn_interfaces[1].ip_address
}

# Output the GCP Cloud Router's ASN
output "gcp_router_asn" {
  description = "The BGP Autonomous System Number (ASN) of the Cloud Router"
  value       = google_compute_router.cloud_router.bgp[0].asn
}