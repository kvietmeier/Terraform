###===================================================================================###
#   File:           private.auto.tfvars
#   Author:         Karl Vietmeier
#
#   Purpose:        Define sensitive, project-specific, or user-specific variable values
#                   for a Terraform configuration. This file contains values that should
#                   **not** be committed to version control.
#
#   Notes:
#     - Terraform automatically loads this file when running commands (plan/apply).
#     - This file is explicitly listed in `.gitignore` to prevent accidental commits.
#     - This is the ideal location for sensitive data like private IPs, secrets, or API keys.
#     - **Do not share this file.** It is for local use only.
#
#   Used By:
#     - fw.main.tf            → Defines firewall resources
#     - fw.variables.tf       → Declares expected input variables
#
#   Usage:
#     Simply run `terraform plan` or `terraform apply`. Terraform will automatically
#     read the variables from this file.
#
###===================================================================================###

# Azure Public IPs from VPN Gateway Configuration
azure_public_ip_01 = "20.121.130.26"
azure_public_ip_02 = "172.172.233.46"


ingress_filter = [
  ###--- Individual External IPs
  "47.144.96.167",    # MyISPAddress
  "47.44.178.111",    # MobileIP
  "47.37.190.104",   # MobileIP
  "10.241.165.219",   # Josh W.(Cato IP)
  "172.56.180.122",   # Arrakis HotSpot
  "69.181.233.114",   # Casey - VAST Support
  "38.97.31.114",     # Bryan Gilcrease
  "71.201.117.34",    # Kartik
  "10.241.247.82",    # CATO IP
  "24.113.69.73",     # Dad's House
  
  ###--- Azure CIDRs allowed through VPN Gateway Configuration
  "10.202.81.0/25",
  "10.202.85.0/25",
  "10.202.85.160/27",
  #"10.223.0.0/21",

  ###--- Fed Lab CIDRs
  "172.69.0.0/24",    ###- Fed Lab CDIR
  "172.60.0.0/23",    ###- Fed Lab CDIR
  #
  ###--- Internal GCP service rnges
  #
  "35.191.0.0/16",    # GCP services range for health checks and managed services
  "130.211.0.0/22",   # GCP services range for health checks and managed services
  "199.36.153.4/30",  # Private Google APIs
  "199.36.153.8/30",  # Private Google APIs
  # These are for AD/DNS/IAP Proxy
  "35.235.240.0/20",  # IAP Source CIDR (for Active Directory and IAP Proxy)
  "35.199.192.0/19",  # Cloud DNS
  #
  ###--- Docker/K8S
  #
  "10.1.0.0/16",      # K8S Pod CIDR
  "10.152.183.0/24",  # K8S Service CIDR
  "192.168.0.0/16",   # Private CIDR Range
  "172.16.0.0/16",    # Docker private networks

  #"169.254.21.8/30",    # For VPN/bGP
  #"169.254.21.12/30",   # For VPN/bGP

  #
  ###--- My subnets: Added by me (I use 10.100-199)
  #"1001::/64",        # ipv6
  "34.20.1.0/24",     # CoreVPC subnet
  "34.21.1.0/24",     # CoreVPC subnet
  "34.22.1.0/24",     # CoreVPC subnet
  "33.20.1.0/24",     # CoreVPC subnet
  "33.21.1.0/24",     # CoreVPC subnet
  "33.22.1.0/24",     # CoreVPC subnet
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
  "192.21.0.0/16",    # CoreVPC CIDR
  "172.9.1.0/24"      # 
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
  "2049",  # NFS
  "3128",  # VAST - Call Home Proxy
  "3268",  # LDAP catalouge
  "3269",  # LDAP catalouge ssl
  "4000",  # VAST - Dnode internal
  "4001",  # VAST - Dnode internal
  "4100",  # VAST - Dnode internal
  "4101",  # VAST - Dnode internal
  "4200",  # VAST - Cnode internal
  "4201",  # VAST - Cnode internal
  "4420",  # spdk target
  "4520",  # spdk target
  "5000",  # docker registry
  "5200",  # VAST - Cnode internal data-env
  "5201",  # VAST - Cnode internal data-env
  "5551",  # VAST - vms_monitor
  "6000",  # VAST - leader
  "6001",  # VAST - leader
  "6126",  # mlx sharpd
  "7000",  # VAST - Dnode internal
  "7001",  # VAST - Dnode internal
  "7100",  # VAST - Dnode internal
  "7101",  # VAST - Dnode internal
  "8000",  # VAST - mcvms
  "9090",  # Tabular
  "9092",  # Kafka
  "20048", # mount
  "20106", # NSM
  "20107", # NLM
  "20108", # NFS_RQUOTA
  "49001", # VAST - replication
  "49002", # VAST - replication
  ### VAST Optional
  "1611",  # VAST Optional - For vperfsanity/elbencho
  "1612",  # VAST Optional - For vperfsanity/elbencho
  "2611",  # VAST Optional - For --netbench 
  "5001"   # VAST Optional - Specsfs2020
]

###--- For 5.3.1 and newer - Added UDP ports.
vast_udp = [
  "4005",      # VAST - Dnode1 platform CAS
  "4105",      # VAST - Dnode1 data CAS
  "4205",      # VAST - CAS Operations
  "5205-5241", # VAST - Cnode silos CAS
  "6005",      # VAST - Leader CAS
  "7005",      # VAST - Dnode2 Platform CAS
  "7105"       # VAST - Dnode2 data CAS
]

###--- For Spark on VAST
spark_tcp = [
  "8081",      # Spark Master Port
  "8481",      # Spark Web UI
  "8080",      # Spark Application UI
  "8480",      # Spark Application UI
  "6066",      # Spark REST API
  "7077",      # Spark Master Port
  "18080",     # Spark History Server - Web UI
  "18480",     # Spark History Server - Web UI
  "4040",      # Connect Server - Web UI
  "4440",      # Connect Server - Web UI
  "15002",     # Connect Server - GRP API
  "4041",      # Trift Server - Web UI
  "4441",      # Trift Server - Web UI
  "10000",     # Trift Server - Thrift API
  "10001"      # Trift Server - Thrift over HTTP API
]

spark_vast_tcp = [
  "9293",      # Worker - Web UI
  "9493",      # Worker - Web UI
  "9292",      # Master - Web UI
  "9492",      # Master - Web UI
  "6066",      # Master - REST API
  "2424",      # Master - RPC
  "18080",     # History Server - Web UI
  "18480",     # History Server - Web UI
  "4040",      # Connect Server - Web UI
  "4440",      # Connect Server - Web UI
  "15002",     # Connect Server - GRP API
  "4041",      # Trift Server - Web UI
  "4441",      # Trift Server - Web UI
  "10000",     # Trift Server - Thrift API
  "10001"      # Trift Server - Thrift over HTTP API
]