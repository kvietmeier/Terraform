###===================================================================================###
#  File:        fw.terraform.tfvars
#  Author:      Karl Vietmeier
#
#  Purpose:     Define environment-specific values for firewall rule provisioning
#               in the 'karlv-corevpc' VPC using Terraform. This file contains
#               project, region, network, port lists, CIDR allowlists, and
#               scoped target tags used by `fw.main.tf`.
#
#  Notes:
#    - This file is excluded from version control (.gitignore).
#    - Update IP addresses, ports, and priorities as needed per environment.
#    - Supports multiple security zones: standard services, VAST, AD, ICMP control.
#
#  Used By:
#    - fw.main.tf            → Defines firewall resources
#    - fw.variables.tf       → Declares expected input variables
#
#  Usage:
#    terraform plan -var-file="fw.terraform.tfvars"
#    terraform apply --auto-approve -var-file="fw.terraform.tfvars"
#    terraform destroy --auto-approve -var-file="fw.terraform.tfvars"
#
###===================================================================================###

# Project Info
project_id      = "clouddev-itdesk124"
region          = "us-west2"
zone            = "us-west2-a"

# VPC Config
vpc_name        = "karlv-corevpc"
description     = "Setup common ports and service FW rules for the core vpc"
#app_description = "Ports for Vast on Cloud"

###--- Firewall and Rules
ingress_rule     = "INGRESS"
egress_rule      = "EGRESS"
myrules_name     = "core-firewall-rules"
addc_name        = "ad-rules"
vast_rules_name  = "vast-rules"
svcs_priority    = "500"
vast_priority    = "500"
addc_priority    = "501"
egress_priority  = "1000"

# Destination port list - external access on public IP
#public_tcp_ports      = [ "21", "22", "45", "53", "80", "88", "443", "445", "3306", "3389", "8080" ]
#public_udp_ports      = [ "21", "22", "53" ]  # DNS and FTP

# Destination port list - standard services you might need between VMs in a VPC
tcp_ports      = [ "20", "21", "22", "45", "53", "80", "88", "119", "443", "445", "563", "3389", "8080" ]
udp_ports      = [ "53", "67", "68" ]  # DNS and DHCP

# For Active Directory Replication
addc_tcp_ports = ["53", "88", "135", "137", "138", "139", "389", "445", "636", "49152-65535"]
addc_udp_ports = ["53", "88", "123", "135", "137", "138", "389", "445"]


###--- Allow List for standard services and Public IPs- modify as needed
###    Ingress filter is excluded from GitHub



### Notes - 
# RPC endpoint mapper: port 135 TCP, UDP
# NetBIOS name service: port 137 TCP, UDP
# NetBIOS datagram service: port 138 UDP
# NetBIOS session service: port 139 TCP
# SMB over IP (Microsoft-DS): port 445 TCP, UDP
# LDAP: port 389 TCP, UDP
# LDAP over SSL: port 636 TCP
# Global catalog LDAP: port 3268 TCP
# Global catalog LDAP over SSL: port 3269 TCP
# Kerberos: port 88 TCP, UDP
# DNS: port 53 TCP, UDP
