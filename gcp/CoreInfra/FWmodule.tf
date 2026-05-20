#### License

``` text
SPDX-License-Identifier: Apache-2.0
```
### Create Custom GCP Firewall Rules

This set of rules will open a specific set of ports for common services and additional ports for applications, and filter incoming traffic on public interfaces to specific IPs and/or IP ranges.

It is written to allow you to easily and quickly update the FW rules as your local IP changes (hotel, coffee shop, etc.) or you need to allow additional people into your VPC.

The ingress rules and VAST Data IP/UDP ports are excluded from GitHub by placing them in a separate private.auto.tfvars file, which is not committed to version control.

---

#### How to Use

1. Create Your Private Variables File:
   Create a new file named `private.auto.tfvars` in the same directory as `fw.main.tf`.
2. Add `private.auto.tfvars` to `.gitignore`.
3. Add Your Sensitive Data:
   In the `private.auto.tfvars` file, add your list of private/public IP addresses and ranges:

```hcl
   ingress_filter = [
   "123.45.67.89/32",  # Example: My Local IP
   "192.0.2.0/24",     # Example: My Office CIDR
   # ... add other private IPs here ...
   ]
```

---

#### Author/s

* **Karl Vietmeier**

---

#### License

This project is licensed under the Apache License - see the [LICENSE.md](LICENSE.md) file for details
###===================================================================================###
#  File:        fw.block.public.tf
#  Author:      Karl Vietmeier
#
#  Purpose:     Define a firewall rule to block common administrative and
#               diagnostic protocols (ICMP, SSH, RDP, SMB) from the public
#               internet for the ‘karlv-corevpc’ VPC on GCP.
#
#  Contents:
#    - deny_public_ingress   → Blocks ICMP, TCP/22, TCP/3389, TCP/445, UDP/445
#
#  Related Files:
#    - fw.main.tf            → Main firewall rule definitions
#    - fw.terraform.tfvars   → Variable values for project, tags, CIDRs, etc.
###===================================================================================###

###--- Create the FW Rule to Deny ICMP, SSH, RDP, and SMB from the Public Internet
resource "google_compute_firewall" "deny_public_ingress" {
  name        = "deny-public-ingress"
  network     = var.vpc_name
  description = "Deny incoming ICMP, SSH, RDP, and SMB traffic from public IPs"
  direction   = "INGRESS"
  priority    = 1000

  # Block ICMP
  deny {
    protocol = "icmp"
  }

  # Block SSH (22), RDP (3389), SMB (445) over TCP
  deny {
    protocol = "tcp"
    ports    = ["22", "3389", "445"]
  }

  # Block SMB over UDP
  deny {
    protocol = "udp"
    ports    = ["445"]
  }

  # Anything not explictly on the ingress list
  source_ranges = ["0.0.0.0/0"]

  # Optional: restrict to specific target tags
  # target_tags = ["no-public-access"]

  disabled = false
}
###===================================================================================###
#  File:        fw.main.tf
#  Author:      Karl Vietmeier
#
#  Purpose:     Define and apply custom firewall rules for the 'karlv-corevpc' VPC 
#               on Google Cloud Platform (GCP). Rules are scoped using target tags 
#               to enforce role-based access for standard services, Active Directory,
#               VAST infrastructure, and security controls (e.g., ICMP restrictions).
#
#  Usage:
#    terraform plan -var-file="fw.terraform.tfvars"
#    terraform apply --auto-approve -var-file="fw.terraform.tfvars"
#    terraform destroy --auto-approve -var-file="fw.terraform.tfvars"
#
#  Structure:
#    - Standard service rules (TCP, UDP, ICMP for SSH, DNS, HTTP, etc.)
#    - Application-specific rules (e.g., VAST on Cloud)
#    - Active Directory support (LDAP, Kerberos, DNS, etc.)
#    - ICMP control: allow trusted sources, deny public pings
#
#  Related Files:
#    - fw.variables.tf       → Variable declarations
#    - fw.terraform.tfvars   → Environment-specific values (excluded from repo)
#
###===================================================================================###

###===================================================================================###
#     Start creating infrastructure resources
###===================================================================================###

###--- Create the FW Rule/s for standard services
resource "google_compute_firewall" "default_services_rules" {
  
  name        = var.myrules_name
  network     = var.vpc_name              
  description = var.description
  priority    = var.svcs_priority
  direction   = var.ingress_rule

  allow {
    protocol = "tcp"
    ports    = var.tcp_ports
  }
  
  allow {
    protocol = "udp"
    ports    = var.udp_ports
  }

  allow {
    protocol = "icmp"                    # ICMP for ping/diagnostic
  }

  source_ranges = var.ingress_filter     # CIDR - Ingress filter
  
  # Optional: restrict to specific target tags
  #target_tags = ["standard-services"]   # Tag for instances needing this firewall rule

}

###--- Create the FW Rule/s for Applications
resource "google_compute_firewall" "custom_app_rules" {
  
  name        = var.vast_rules_name
  network     = var.vpc_name              
  description = var.description
  direction   = var.ingress_rule
  priority    = var.vast_priority

  
  allow {
    protocol = "tcp"
    ports    = var.vast_tcp
  }

  allow {
    protocol = "udp"
    ports    = var.vast_udp
  }

  allow {
    protocol = "icmp"                    # ICMP for ping/diagnostic
  }

  source_ranges = var.ingress_filter     # CIDR - Ingress filter
  
  # Optional: restrict to specific target tags
  #target_tags = ["standard-services"]   

}

###--- Create the FW Rule/s for Active Directory
resource "google_compute_firewall" "addc_rules" {
  
  ###--- Rules for Active Directory
  name        = var.addc_name
  network     = var.vpc_name              
  description = var.description
  direction   = var.ingress_rule
  priority    = var.addc_priority

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = var.addc_tcp_ports
  }

  allow {
    protocol = "udp"
    ports    = var.addc_udp_ports
  }

  source_ranges = var.ingress_filter     # CIDR - Ingress filter
  
  # Optional: restrict to specific target tags
  #source_tags   = ["ad-domaincontroller"]
  #target_tags   = ["ad-domaincontroller"]
}

resource "google_compute_firewall" "allow_ha_vpn_bgp" {
  name          = "allow-ha-vpn-control" # Renamed for clarity
  network       = var.vpc_name
  direction     = "INGRESS"
  description   = "Allow IKE/IPsec/BGP from Azure Public IPs for HA VPN establishment"
  
  # CRITICAL: Priority must be low (e.g., 100) for security, 
  # NOT 1000, which is the default internet route priority.
  priority      = 100 

  # --- IPsec/IKE Protocols from the Azure Public Gateway ---
  allow {
    protocol = "tcp"
    ports    = ["179"] 	# BGP (Though often unneeded if tunnel is established)
  }

  allow {
    protocol = "udp"
    ports    = ["500", "4500"] 	# IKE (500) + NAT-T (4500)
  }

  allow {
    protocol = "esp" 			# IPsec ESP traffic (Required for data integrity)
  }

  # CRITICAL: Use the Azure Public Gateway IPs as the source.
  source_ranges = [
    var.azure_public_ip_01,
    var.azure_public_ip_02
  ]
}
###===================================================================================###
#
#  File:  provider.tf
#  Created By: Karl Vietmeier
#
#  Purpose: Configure the GCP Provider TerraForm
# 
#  Google defaults set as Env: vars
#
###===================================================================================###

terraform {
  backend "gcs" {
    bucket  = "clouddev-itdesk124-tfstate"
    prefix  = "terraform/state/myfwrules"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.9.0"
    }
    #google-beta = {
    #  source  = "hashicorp/google-beta"
    #  version = ">= 5.9.0"
    #}
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}
﻿###===================================================================================###
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
project_id = "clouddev-itdesk124"
region     = "us-west2"
zone       = "us-west2-a"

# VPC Config
vpc_name   = "karlv-corevpc"
description = "Setup common ports and service FW rules for the core VPC"

###--- Firewall and Rules

ingress_rule    = "INGRESS"
egress_rule     = "EGRESS"

myrules_name    = "core-firewall-rules"
addc_name       = "ad-rules"
vast_rules_name = "vast-rules"

# FIXED: numbers instead of strings
svcs_priority   = 500
vast_priority   = 500
addc_priority   = 501
egress_priority = 1000

###--- Ingress Source Filters (REQUIRED)

ingress_filter = [
  "10.0.0.0/8",
  "192.168.0.0/16"
]

###--- Standard Service Ports

tcp_ports = [
  "20", "21", "22", "45", "53", "80",
  "88", "119", "443", "445", "563",
  "3389", "5173", "8080"
]

udp_ports = [
  "53", "67", "68"
]

###--- Active Directory Ports

addc_tcp_ports = [
  "53", "88", "135", "137", "138",
  "139", "389", "445", "636",
  "49152-65535"
]

addc_udp_ports = [
  "53", "88", "123", "135",
  "137", "138", "389", "445"
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
###===================================================================================###
#  File:        fw.terraform.tfvars
#  Author:      Karl Vietmeier
#
#  Purpose:     Environment‑specific settings for firewall provisioning in the
#               ‘karlv-corevpc’ VPC. Replace placeholders with your actual values.
###===================================================================================###

# Project & Location
project_id      = "<YOUR_PROJECT_ID>"
region          = "<YOUR_REGION>"
zone            = "<YOUR_ZONE>"

# VPC & Descriptions
vpc_name        = "<YOUR_VPC_NAME>"
description     = "Firewall rules for core VPC"

# Rule Metadata
ingress_rule    = "INGRESS"
egress_rule     = "EGRESS"
myrules_name    = "core-firewall-rules"
vast_rules_name = "vast-rules"
addc_name       = "ad-rules"
svcs_priority   = 500
vast_priority   = 500
addc_priority   = 501
egress_priority = 1000

# Target Tags
standard_services_tags = ["standard-services"]
vast_tags              = ["vast-app"]
addc_tags              = ["ad-controller"]
no_icmp_tags           = ["no-icmp"]

# Port Lists

# Standard services (TCP/UDP/ICMP)
tcp_ports = [
  "20", "21", "22", "45", "53", "80", "88",
  "119", "443", "445", "563", "3389", "8080"
]
udp_ports = ["53", "67", "68"]

# Active Directory replication & services
addc_tcp_ports = [
  "53", "88", "135", "137", "138", "139",
  "389", "445", "636", "49152-65535"
]
addc_udp_ports = ["53", "88", "123", "135", "137", "138", "389", "445"]

# VAST‑on‑Cloud required TCP ports
vast_tcp = [
  "22", "80", "111", "389", "443", "445", "636",
  "1611", "1612", "2611", "2049", "3268", "3269",
  "4420", "4520", "5000", "6126", "9090", "9092",
  "20048", "20106", "20107", "20108", "6000", "6001",
  "3128", "4000", "4001", "4100", "4101", "4200",
  "4201", "5200", "5201", "5551", "7000", "7001",
  "7100", "7101", "8000", "49001", "49002"
]

# Ingress Filters
ingress_filter = [
  # Trusted external IPs (replace with yours)
  "<IP_A>", "<IP_B>", "<IP_C>",

  # On‑prem/Data center CIDRs
  "10.0.0.0/8",     # example
  "172.16.0.0/12",  # example

  # GCP service ranges
  "35.191.0.0/16",
  "130.211.0.0/22",
  "199.36.153.8/30",
  "35.235.240.0/20",
  "35.199.192.0/19",

  # Internal network CIDRs (add your internal ranges here)
  # "<INTERNAL_CIDR_1>",
  # "<INTERNAL_CIDR_2>",

  # Kubernetes/Docker networks
  "10.1.0.0/16",
  "10.152.183.0/24"
]
###===================================================================================###
#  File:        fw.variables.tf
#  Author:      Karl Vietmeier (Refactored by Gemini Code Assist)
#
#  File:  fw.variables.tf
#  Created By: Karl Vietmeier
#  Purpose:     Variable definitions for custom firewall rules.
#
#  Variable definitions with defaults
#  Structure:
#    - `ingress_firewall_rules`: A map of rule objects to dynamically create firewall
#      rules, reducing code duplication.
#    - `vpc_name`: The target VPC for the firewall rules.
#    - `ingress_filter`: Source IP ranges for ingress traffic.
#    - HA VPN specific variables for the BGP peering connection.
#
###===================================================================================###

###--- Provider Info

variable "region" {
  description = "Region to deploy resources"
  type        = string
}

variable "zone" {
  description = "Availability Zone"
  type        = string
}

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

###--- Dynamic Firewall Rules

variable "ingress_firewall_rules" {
  description = "A map of custom ingress firewall rules to create."
  type = map(object({
    name        = string
    description = string
    priority    = number
    allow = list(object({
      protocol = string
      ports    = optional(list(string), [])
    }))
    target_tags = optional(list(string), [])
  }))
  default = {}
}

###--- VPC Setup

variable "vpc_name" {
  description = "The name of the VPC network where firewall rules will be applied."
  type        = string
  default     = "default"
}

variable "ingress_filter" {
  description = "A list of source CIDR ranges to allow for ingress rules."
  type        = list(string)
}

###--- Firewall Direction

variable "ingress_rule" {
  description = "The direction for ingress firewall rules."
  type        = string
  default     = "INGRESS"
}

variable "egress_rule" {
  description = "The direction for egress firewall rules."
  type        = string
  default     = "EGRESS"
}

variable "description" {
  description = "General description for firewall rules"
  type        = string
}

###--- Firewall Rule Names

variable "myrules_name" {
  description = "Standard TCP/UDP services rule name"
  type        = string
}

variable "addc_name" {
  description = "Active Directory rule name"
  type        = string
}

variable "vast_rules_name" {
  description = "VAST Data rule name"
  type        = string
}

###--- Priorities

variable "svcs_priority" {
  description = "Priority for standard services"
  type        = number
  default     = 500
}

variable "vast_priority" {
  description = "Priority for VAST rules"
  type        = number
  default     = 500
}

variable "addc_priority" {
  description = "Priority for AD rules"
  type        = number
  default     = 501
}

variable "egress_priority" {
  description = "Priority for egress rules"
  type        = number
  default     = 1000
}

###--- Destination Port Lists

variable "all_ports" {
  description = "Represents all ports for egress"
  type        = string
  default     = "ALL"
}

variable "tcp_ports" {
  description = "Standard TCP ports (SSH, RDP, etc.)"
  type        = list(string)
}

variable "udp_ports" {
  description = "Standard UDP ports"
  type        = list(string)
}

variable "spark_tcp" {
  description = "Ports for Spark"
  type        = list(string)
}

variable "spark_vast_tcp" {
  description = "Ports for VAST Spark"
  type        = list(string)
}

variable "addc_tcp_ports" {
  description = "TCP ports for Active Directory"
  type        = list(string)
}

variable "addc_udp_ports" {
  description = "UDP ports for Active Directory"
  type        = list(string)
}

variable "vast_tcp" {
  description = "TCP ports required for VAST Data"
  type        = list(string)
}

variable "vast_udp" {
  description = "UDP ports required for VAST Data"
  type        = list(string)
}

###--- HA VPN Control Plane Variables

variable "azure_public_ip_01" {
  description = "Public IP of the first Azure VPN gateway for HA VPN."
  type        = string
}

variable "azure_public_ip_02" {
  description = "Public IP of the second Azure VPN gateway for HA VPN."
  type        = string
}﻿###===================================================================================###
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

# Azure Public IPs
azure_public_ip_01 = "20.91.221.126"
azure_public_ip_02 = "20.91.231.34"

ingress_filter = [
  ###--- External IPs (converted to /32)
  "47.144.88.204/32",
  "47.44.178.111/32",
  "47.37.190.104/32",
  "216.194.63.10/32",
  "157.157.64.73/32",
  "10.241.165.219/32",
  "192.116.36.234/32",
  "84.110.32.226/32",
  "172.56.180.122/32",
  "69.181.233.114/32",
  "38.97.31.114/32",
  "71.201.117.34/32",
  "10.241.247.82/32",
  "24.113.69.73/32",

  ###--- Azure CIDRs
  "10.202.81.0/25",
  "10.202.85.0/25",
  "10.202.85.160/27",
  "192.168.4.0/22",
  "10.50.0.0/20",

  ###--- Fed Lab
  "172.69.0.0/24",
  "172.60.0.0/23",

  ###--- GCP Service Ranges
  "35.191.0.0/16",
  "130.211.0.0/22",
  "199.36.153.4/30",
  "199.36.153.8/30",
  "35.235.240.0/20",
  "35.199.192.0/19",

  ###--- Docker/K8S
  "10.1.0.0/16",
  "10.152.183.0/24",
  "192.168.0.0/16",
  "172.16.0.0/16",

  ###--- Custom Subnets (VERIFY THESE)
  "34.20.1.0/24",
  "34.21.1.0/24",
  "34.22.1.0/24",

  # These look suspicious (public ranges?)
  "33.20.1.0/24",
  "33.21.1.0/24",
  "33.22.1.0/24",

  # Not RFC1918 private - subnet ranges that may be used in the environment
  "172.1.1.0/24",
  "172.1.2.0/23",
  "172.1.4.0/23",
  "172.1.6.0/24",
  "172.3.1.0/26",
  "172.4.1.0/27",
  "172.5.0.0/16",
  "172.6.0.0/16",
  "172.7.0.0/16",
  "172.8.0.0/16",
  "172.10.0.0/20",
  "172.20.0.0/14",
  "172.30.0.0/16",
  "192.21.0.0/16",
  "172.9.1.0/24"
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
  "4101",      # VAST - Dnode1 data CAS
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