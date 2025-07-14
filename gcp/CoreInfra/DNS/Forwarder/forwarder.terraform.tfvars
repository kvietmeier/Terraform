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

# DNS forwarding zone configuration
name           = "forwarding-domain"
dns_name       = "busab.org."              # Must be a fully-qualified domain (ends with a dot)
description    = "VIP Protocol Pool IPs"

# DNS forwarding configuration
vastcluser_dns  = "172.1.4.110"  # IP of the DNS server on the VAST cluster
forwarding_path = "private"      # "default" or "private" per GCP DNS spec

# VPC networks with access to this DNS zone
networks = [
  "karlv-corevpc"
]