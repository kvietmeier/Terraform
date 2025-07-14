###===================================================================================###
#
#  File:  fw.terraform.tfvars
#  Created By: Karl Vietmeier
#
#  This file is excluded from the repo. 
#
#  Edit as required
#
###===================================================================================###

# Project Info
project_id      = "clouddev-itdesk124"
region          = "us-west2"
zone            = "us-west2-a"

# VPC Config
vpc_name        = "default"
description     = "Open all of the IP and UDP ports"

rule_direction  = "INGRESS"
rule_priority   = "10"

# Everything
ports = [ "0-65535" ]


ingress_filter = [
  ###--- External IPs
  "47.144.102.211",   # MyISPAddress
  "192.192.192.1",    # MobileIP
  "10.241.165.219",   # Josh W.(Cato IP)
  "172.56.180.122",   # Arrakis HotSpot
  "172.69.0.0/24",    ###- Fed Lab CDIR
  "172.60.0.0/24",    # 
  "172.61.0.0/24",    ###- Fed Lab CDIR
  "69.181.233.114",   # Casey - VAST Support
  #"47.44.178.107",    ###- Cerritos Library
  #
  ###--- Internal GCP subnets
  #
  "35.191.0.0/16",    # GCP services range for health checks and managed services
  "130.211.0.0/22",   # GCP services range for health checks and managed services
  # These are for AD/DNS
  "35.235.240.0/20",  # IAP Source CIDR (for Active Directory)
  "35.199.192.0/19",  # Cloud DNS
  # Docker/K8S
  "10.1.0.0/16",      # K8S Pod CIDR
  "10.152.183.0/24",  # K8S Service CIDR
  "192.168.0.0/16",   # ???
  "172.16.0.0/16",    # Docker private networks
  ###--- My subnets: Added by me (I use 10.100-199)
  #"1001::/64",        # ipv6
  "172.20.0.0/16",    # CoreVPC CIDR - allows 172.20.../20 - 172.21.../20
  "192.21.0.0/16",    # CoreVPC CIDR (IPv6 subnets)
  "172.30.0.0/16",    # Spoke1 CIDR - all /24
  "172.3.1.0/26",     # CoreVPC subnet
  "172.4.1.0/27",     # CoreVPC subnet
  "172.1.1.0/24",     # CoreVPC subnet
  "172.1.2.0/24",     # CoreVPC subnet
  "172.1.3.0/24",     # CoreVPC subnet
  "172.1.4.0/24",     # CoreVPC subnet
  "172.1.5.0/24",     # CoreVPC subnet
  "172.1.6.0/24"      # CoreVPC subnet
]
