###===================================================================================###
#   Copyright (C) 2022 Intel Corporation
#   SPDX-License-Identifier: Apache-2.0
###===================================================================================###
#
#  File:  terraform.tfvars
#  Created By: Karl Vietmeier
#
#  This is a "sanitized" version of the terraform.tfvars file that is excluded from the repo. 
#  Any values that aren't sensitive are left defined, amy sensitive values are stubbed out.
#
#  Edit as required
#
###===================================================================================###


# --- Azure Infrastructure Config ---
subscription_id      = "YOUR_AZURE_SUBSCRIPTION_ID" # <--- REPLACE THIS
resource_group_name  = "rg-azure-vpn-central1"
location             = "Central US"
vnet_name            = "vnet-azure-core"
gateway_name         = "vpngw-azure-central1"

# --- BGP Configuration ---
azure_asn            = "65010"
azure_apipa_bgp_a    = "169.254.21.10"
azure_apipa_bgp_b    = "169.254.22.10"

# --- GCP Side Configuration (Peer Details) ---
gcp_asn              = "65333"
gcp_apipa_bgp_a      = "169.254.21.9"
gcp_apipa_bgp_b      = "169.254.22.9"

# [CRITICAL] These must match the PUBLIC IPs of your existing GCP HA Gateway.
# Run: gcloud compute vpn-gateways describe vpn-gateway-azure-central1 --region=us-central1
gcp_pubip0           = "REPLACE_WITH_GCP_INTERFACE0_IP"
gcp_pubip1           = "REPLACE_WITH_GCP_INTERFACE1_IP"


# --- Security ---
# This must match the key used on the GCP side exactly.
shared_key           = "xVTsD61QPvDUPgD3bJvyaxo6s+peCTD6"