###===================================================================================###
#
#  File:         ad_forwarding.terraform.tfvars
#  Purpose:      Create DNS forwarding zone for Active Directory domain
#  Description:  This configuration sets up a Cloud DNS forwarding zone in GCP to
#                route DNS queries for an Active Directory domain to a specified
#                on-prem or cloud DNS resolver.
#
#  Notes:
#    - The `fw_target` is the IP of the DNS server to which queries should be forwarded.
#    - The zone must be private and attached to one or more VPC networks.
#
#  Author:      Karl Vietmeier 
#
###===================================================================================###

# terraform.tfvars
project_id     = "clouddev-itdesk124"
region         = "us-west3"
zone           = "us-west3-a"

name           = "ad-forwarding-domain"
dns_name       = "ginaz.org."
description    = "Forward AD Queries"

# This might change on you
fw_target = "172.20.16.3"

networks = [
  "karlv-corevpc"
]