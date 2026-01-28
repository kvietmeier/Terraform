# terraform.tfvars
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

project_id          = "clouddev-itdesk124"
region              = "us-central1"
zone                = "us-central1a"
network             = "karlv-corevpc"

# VPN Gateway Setup
ha_vpn_gw_name      = "vpn-gateway-azure-central1"
external_gw_name    = "vpn-gateway-azure-central1"
router_name         = "router-azure-central1"
gcp_asn             = "65333"
shared_key          = "xVTsD61QPvDUPgD3bJvyaxo6s+peCTD6"

tunnel_if0          = "vpn-azure-tunnel0-central1"
tunnel_if1          = "vpn-azure-tunnel1-central1"
interface0          = "vpn-azure-tunnel0-interface0"
interface1          = "vpn-azure-tunnel1-interface1"

### BGP Setup
gcp_apipa_bgp_a     = "169.254.21.9"
gcp_apipa_bgp_b     = "169.254.22.9"
bgp_peer_if0        = "bgp-azure-peer-if0"
bgp_peer_if1        = "bgp-azure-peer-if1"
priority            = 100


### Azure Side
azure_pubip0        = "4.249.107.59"
azure_pubip1        = "4.249.107.48"
azure_apipa_bgp_a   = "169.254.21.10"
azure_apipa_bgp_b   = "169.254.22.10"
azure_asn_b         = "65010"