###===================================================================================###
#
#  File:         forwarding_zone.tfvars
#  Purpose:      Configure a GCP Private DNS Forwarding Zone
#  Description:  Forwards DNS queries to a VAST Data cluster DNS endpoint using 
#                a reserved VIP address in GCP.
#
#  Author:       Karl Vietmeier
#
###===================================================================================###

# GCP project and deployment location
project_id     = "clouddev-itdesk124"
region         = "us-west3"
zone           = "us-west3-a"


# List of VPC Networks that will be able to resolve these DNS zones
networks = [
  "karlv-corevpc"
]

# --- New structure for multiple forwarding zones ---

# 'forwarding_zones' is a map where the key (e.g., 'vast-cluster-1') 
# becomes the internal resource name for the zone in GCP.
forwarding_zones = {
  "vast-cluster-1" = {
    dns_name          = "vastohio.com."   # Must end with a dot
    vastcluser_dns    = "172.9.1.250"             # Target VAST DNS IP 1
    description       = "Forwarder for VAST Cluster 1 DNS"
    forwarding_path   = "private"                  # Optional: "default" or "private"
  },
  "vast-cluster-2" = {
    dns_name          = "vastemea.com."   # Must end with a dot
    vastcluser_dns    = "172.10.11.250"             # Target VAST DNS IP 2
    description       = "Forwarder for VAST Cluster 2 DNS"
    forwarding_path   = "private"
  }
}
