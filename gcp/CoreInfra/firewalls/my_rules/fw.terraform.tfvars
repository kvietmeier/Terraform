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


# Allow List for standard services and Public IPs- modify as needed
#egress_filter = [
#  "0.0.0.0/0"
#]

ingress_filter = [
  ###--- Individual External IPs
  "47.144.102.211",   # MyISPAddress
  "104.167.209.0",    # MobileIP
  "10.241.165.219",   # Josh W.(Cato IP)
  "10.241.165.243",   # Sarah W.(Cato IP)
  "147.235.199.32",   # Ronnie
  "84.110.32.226",    # Ronnie
  "147.235.192.48",   # Sarah W.
  "172.56.180.122",   # Arrakis HotSpot
  "69.181.233.114",   # Casey - VAST Support
  "10.241.247.82",    # CATO IP
  #
  ###--- Fed Lab CIDRs
  "172.69.0.0/24",    ###- Fed Lab CDIR
  "172.60.0.0/23",    ###- Fed Lab CDIR
  #
  ###--- Internal GCP service rnges
  #
  "35.191.0.0/16",    # GCP services range for health checks and managed services
  "130.211.0.0/22",   # GCP services range for health checks and managed services
  "199.36.153.8/30",  # Private Google APIs
  # These are for AD/DNS
  "35.235.240.0/20",  # IAP Source CIDR (for Active Directory)
  "35.199.192.0/19",  # Cloud DNS
  #
  ###--- Docker/K8S
  #
  "10.1.0.0/16",      # K8S Pod CIDR
  "10.152.183.0/24",  # K8S Service CIDR
  "192.168.0.0/16",   # Private CIDR Range
  "172.16.0.0/16",    # Docker private networks
  #
  ###--- My subnets: Added by me (I use 10.100-199)
  #"1001::/64",        # ipv6
  "172.1.1.0/24",     # CoreVPC subnet
  "172.1.2.0/23",     # CoreVPC subnet
  "172.1.4.0/23",     # CoreVPC subnet
  "172.1.6.0/24",     # CoreVPC subnet
  "172.3.1.0/26",     # CoreVPC subnet 
  "172.4.1.0/27",     # CoreVPC subnet
  "172.5.0.0/16",     # 
  "172.6.0.0/16",     # 
  "172.7.0.0/16",     # 
  "172.8.0.0/16",     # 
  "172.10.0.0/20",    # 
  "172.20.0.0/14",    # CoreVPC CIDR - allows 172.20.../20 - 172.21.../20
  "172.30.0.0/16",    # CoreVPC CIDR
  "192.21.0.0/16"     # CoreVPC CIDR
]


### List of ports required for VAST on Cloud
vast_tcp = [
  ### Services used by VAST
  "22",    # SSH
  "80",    # HTTP
  "111",   # rpcbind for NFS
  "389",   # LDAP
  "443",   # HTTPS
  "445",   # SMB
  "636",   # Secure LDAP
  "1611",  # For vperfsanity/elbencho
  "1612",  # For vperfsanity/elbencho
  "2611",  # For --netbench 
  "2049",  # NFS
  "3268",  # LDAP catalouge
  "3269",  # LDAP catalouge ssl
  "4420",  # spdk target
  "4520",  # spdk target
  "5000",  # docker registry
  "6126",  # mlx sharpd
  "9090",  # Tabular
  "9092",  # Kafka
  "20048", # mount
  "20106", # NSM
  "20107", # NLM
  "20108", # NFS_RQUOTA
  ### VAST Specific
  "6000",  # leader
  "6001",  # leader
  "3128",  # Call Home Proxy
  "4000",  # Dnode internal
  "4001",  # Dnode internal
  "4100",  # Dnode internal
  "4101",  # Dnode internal
  "4200",  # Cnode internal
  "4201",  # Cnode internal
  "5200",  # Cnode internal data-env
  "5201",  # Cnode internal data-env
  "5551",  # vms_monitor
  "7000",  # Dnode internal
  "7001",  # Dnode internal
  "7100",  # Dnode internal
  "7101",  # Dnode internal
  "8000",  # mcvms
  "49001", # replication
  "49002"  # replication
]

###--- For 5.3.1 and newer - Added UDP ports.
vast_udp = [
  "4001",      # Dnode internal
  "4005",      # Dnode1 platform CAS
  "4101",      # Dnode internal
  "4105",      # Dnode1 data CAS
  "4205",      # CAS Operations
  "5205-5239", # Cnode silos CAS
  "6005",      # Leader CAS
  "7005",      # Dnode2 Platform CAS
  "7105"       # Dnode2 data CAS
]


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
