#### License

``` text
SPDX-License-Identifier: Apache-2.0
```
### GCP DNS Forwarding Zone for Active Directory

Provisions a **Cloud DNS private forwarding zone** in **Google Cloud Platform (GCP)**. It's typically used to forward DNS queries for an **Active Directory (AD)** domain (e.g., `example.ad.`) to an on-premises or cloud-based DNS server such as one hosted on a **VAST Data cluster** or a domain controller running in a VM.

---

#### Notes

- [GCP: Private DNS Zones](https://cloud.google.com/dns/docs/zones#private)

#### Requirements

- Google Cloud Project with DNS API enabled
- Appropriate IAM permissions to create Cloud DNS zones
- Terraform v1.3+ and Google provider configured

---

#### Author/s

- **Karl Vietmeier**

#### License

This project is licensed under the Apache License - see the [LICENSE.md](LICENSE.md) file for details
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
]###===================================================================================###
#
#  Created By: Karl Vietmeier
#  Purpose:      Create DNS forwarding zone for Active Directory domain
#  Description:  This configuration sets up a Cloud DNS forwarding zone in GCP to
#                route DNS queries for an Active Directory domain to a specified
#                on-prem or cloud DNS resolver.
#
#  Notes:
#    - The `fw_target` is the IP of the DNS server to which queries should be forwarded.
#    - The zone must be private and attached to one or more VPC networks.
#
###===================================================================================###


###===================================================================================###
#                                 Provider Configuration
###===================================================================================###
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

# Configure the Google Cloud provider with the project, region, and zone.
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

###===================================================================================###
#                      Private DNS Managed Zone Configuration
###===================================================================================###
resource "google_dns_managed_zone" "dns_forwarder" {
  # Define the DNS Managed Zone
  name        = var.name
  dns_name    = var.dns_name
  description = var.description
  visibility  = "private"

  # Configure private visibility for the DNS zone
  private_visibility_config {
    # Dynamically add networks from the `var.networks` variable
    dynamic "networks" {
      for_each = var.networks
      content {
        network_url = "https://www.googleapis.com/compute/v1/projects/${var.project_id}/global/networks/${networks.value}"
      }
    }
  }
 
  # Setup this domain up with a forwarder for VAST DNS
  forwarding_config {
    target_name_servers {
      ipv4_address = var.fw_target
    }
  }
}


###===================================================================================###
#                                   Outputs
###===================================================================================###
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
#  Author:  Karl Vietmeier
#
###===================================================================================###

# GCP project and region info
project_id     = "your-gcp-project-id"
region         = "your-region"
zone           = "your-zone"

# DNS forwarding zone configuration
name           = "ad-forwarding-domain"
dns_name       = "example.ad."             # Replace with your AD DNS domain
description    = "Forward AD DNS Queries to on-prem DNS"

# Target DNS server for forwarding
fw_target      = "10.0.0.53"               # Replace with actual on-prem/cloud DNS IP

# VPC networks associated with the forwarding zone
networks = [
  "core-vpc"                              # Replace with actual network name(s)
]
###===================================================================================###
#
#  File:  forwarder.variables.tf
#  Created By: Karl Vietmeier
#
#   This file defines all required input variables for deploying a DNS forwarding zone
#   in Google Cloud, typically used to forward queries to an external DNS server such
#   as an Active Directory DNS on a VAST cluster.
#
###===================================================================================###

###--- GCP Provider Configuration
variable "region" {
  description = "Region to deploy resources"
}

variable "zone" {
  description = "Availbility Zone"
}

variable "project_id" {
  description = "The ID of the Google Cloud project."
  type        = string
}

###--- DNS Zone Configuration
variable "dns_name" {
  description = "The DNS name for the managed zone."
  type        = string
}

variable "name" {
  description = "Name of the resource"
  type        = string
}

variable "description" {
  description = "Description for the managed DNS zone."
  type        = string
}

variable "networks" {
  description = "A list of networks for private visibility."
  type        = list(string)
}

variable "fw_target" {
description = "DNS server on VAST cluster"
type = string

}#### License

``` text
SPDX-License-Identifier: Apache-2.0
```
### Create a Private DNS Domain

Creates a private DNS domain with at least one A record pointing to a group of IPs.

I'm using this to maintain DNS records for VAST VMS VIP Pools.

---

#### Notes

Put Notes Here

---

#### My code is Built With

* [Visual Studio Code](https://code.visualstudio.com/) - Editor
* [Terraform](https://www.terraform.io/) - Terraform

#### All run under PowerShell on Windows 11

* [Windows Terminal](https://docs.microsoft.com/en-us/windows/terminal/) - Console

#### Author/s

* **Karl Vietmeier**

#### License

This project is licensed under the Apache License - see the [LICENSE.md](LICENSE.md) file for details

#### Acknowledgments

* None so far other than the many good examples out there.
###===================================================================================###
#
#  File:  dns1.terraform.tfvars
#  Created By: Karl Vietmeier
#
#  This creates A records for a reserved CIDR in GCP for VAST VIP addresses
#
###===================================================================================###

# terraform.tfvars
project_id     = "clouddev-itdesk124"
region         = "us-west3"
zone           = "us-west3-a"

dns_name       = "arrakis.org."
description    = "VIP Pool IPs"

# This might change on you
vastcluser_dns = "172.1.4.254"

networks = [
  "karlv-corevpc"
]

a_records = {
  # Protocol Pool VIPs
  "protpool1"    = ["172.1.3.10"],
  "protpool2"    = ["172.1.3.11"],
  "protpool3"    = ["172.1.3.12"],
  "protpool4"    = ["172.1.3.13"],
  "protpool5"    = ["172.1.3.14"],
  "protpool6"    = ["172.1.3.15"],
  "protpool7"    = ["172.1.3.16"],
  "protpool8"    = ["172.1.3.18"],
  "protpool9"    = ["172.1.3.19"],
  "protpool10"   = ["172.1.3.20"],
  "protpool11"   = ["172.1.3.21"],
  # Replication Pool VIPs
  "reppool1"     = ["172.1.3.22"],
  "reppool2"     = ["172.1.3.23"],
  "reppool3"     = ["172.1.3.24"],
  "reppool4"     = ["172.1.3.26"],
  "reppool5"     = ["172.1.3.27"],
  "reppool6"     = ["172.1.3.28"],
  "reppool7"     = ["172.1.3.29"],
  "reppool8"     = ["172.1.3.30"],
  "reppool9"     = ["172.1.3.31"],
  "reppool10"    = ["172.1.3.32"],
  "reppool11"    = ["172.1.3.33"],
  # For sharing views via routing
  "sharevip1"    = ["33.20.1.11"],
  "sharevip2"    = ["33.20.1.12"],
  "sharevip3"    = ["33.20.1.13"],
  "sharevip4"    = ["33.20.1.14"],
  "sharevip5"    = ["33.20.1.15"],
  "sharevip6"    = ["33.20.1.16"],
  "sharevip7"    = ["33.20.1.17"],
  "sharevip8"    = ["33.20.1.18"],
  "sharevip9"    = ["33.20.1.19"],
  "sharevip10"   = ["33.20.1.20"],
  "sharevip11"   = ["33.20.1.21"],
  # For VIP failover via routing
  "repvip1"      = ["33.21.1.11"],
  "repvip2"      = ["33.21.1.12"],
  "repvip3"      = ["33.21.1.13"],
  "repvip4"      = ["33.21.1.14"],
  "repvip5"      = ["33.21.1.15"],
  "repvip6"      = ["33.21.1.16"],
  "repvip7"      = ["33.21.1.17"],
  "repvip8"      = ["33.21.1.18"],
  "repvip9"      = ["33.21.1.19"],
  "repvip10"     = ["33.21.1.20"],
  "repvip11"     = ["33.21.1.21"],
  # For VIP failover via routing
  "s3vip1"       = ["33.22.1.11"],
  "s3vip2"       = ["33.22.1.12"],
  "s3vip3"       = ["33.22.1.13"],
  "s3vip4"       = ["33.22.1.14"],
  "s3vip5"       = ["33.22.1.15"],
  "s3vip6"       = ["33.22.1.16"],
  "s3vip7"       = ["33.22.1.17"],
  "s3vip8"       = ["33.22.1.18"],
  "s3vip9"       = ["33.22.1.19"],
  "s3vip10"      = ["33.22.1.20"],
  "s3vip11"      = ["33.22.1.21"],
  #
  # Clients/Linux Hosts
  #
  #"client01"   = ["172.20.96.91"],
  #"client02"   = ["172.20.96.92"],
  #"client03"   = ["172.20.96.93"],
  #"client04"   = ["172.20.96.94"],
  #"client05"   = ["172.20.96.95"],
  #"client06"   = ["172.20.96.96"],
  #"client07"   = ["172.20.96.97"],
  #"client08"   = ["172.20.96.98"],
  #"client09"   = ["172.20.96.99"],
  #"client10"  = ["172.20.96.100"],
  #"client11"  = ["172.20.96.101"],
  # A-Record Protocl Alias
  "protovip" = [
    "172.1.3.100",
    "172.1.3.101",
    "172.1.3.102",
    "172.1.3.103",
    "172.1.3.104",
    "172.1.3.105",
    "172.1.3.106",
    "172.1.3.107",
    "172.1.3.108",
    "172.1.3.109",
    "172.1.3.110",
  ],  
  "repvip" = [
    "172.1.3.46",
    "172.1.3.47",
    "172.1.3.48",
    "172.1.3.49",
    "172.1.3.50",
    "172.1.3.51",
    "172.1.3.52",
    "172.1.3.53",
    "172.1.3.54",
    "172.1.3.55",
    "172.1.3.56",
  ],  
  "sharevip" = [
    "33.20.1.11",
    "33.20.1.12",
    "33.20.1.13",
    "33.20.1.14",
    "33.20.1.15",
    "33.20.1.16",
    "33.20.1.17",
    "33.20.1.18",
    "33.20.1.19",
    "33.20.1.20",
    "33.20.1.21",
  ],
  "vastrep1" = [
    "33.21.1.11",
    "33.21.1.12",
    "33.21.1.13",
    "33.21.1.14",
    "33.21.1.15",
    "33.21.1.16",
    "33.21.1.17",
    "33.21.1.18",
    "33.21.1.19",
    "33.21.1.20",
    "33.21.1.21",
  ],  
  "s3vip" = [
    "33.22.1.11",
    "33.22.1.12",
    "33.22.1.13",
    "33.22.1.14",
    "33.22.1.15",
    "33.22.1.16",
    "33.22.1.17",
    "33.22.1.18",
    "33.22.1.19",
    "33.22.1.20",
    "33.22.1.21",
  ]
}
###===================================================================================###
#
#  Created By: Karl Vietmeier
#
#  Terraform Module Code
#  Purpose: Create and modify a Private DNS Zone in GCP 
#
###===================================================================================###


###===================================================================================###
#                                 Provider Configuration
###===================================================================================###
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

# Configure the Google Cloud provider with the project, region, and zone.
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

###===================================================================================###
#                      Private DNS Managed Zone Configuration
###===================================================================================###
resource "google_dns_managed_zone" "vastclusters" {
  # Define the DNS Managed Zone
  name        = "vastclusters"
  dns_name    = var.dns_name
  description = var.description
  visibility  = "private"

  # Configure private visibility for the DNS zone
  private_visibility_config {
    # Dynamically add networks from the `var.networks` variable
    dynamic "networks" {
      for_each = var.networks
      content {
        network_url = "https://www.googleapis.com/compute/v1/projects/${var.project_id}/global/networks/${networks.value}"
      }
    }
  }
}

###===================================================================================###
#                     A Records with Multiple IP Addresses
###===================================================================================###
resource "google_dns_record_set" "a_records" {
  # Create A records dynamically based on the input map `var.a_records`
  for_each = var.a_records

  # Set up the A record with multiple IP addresses
  name         = "${each.key}.${var.dns_name}"
  managed_zone = google_dns_managed_zone.vastclusters.name
  type         = "A"
  ttl          = 300
  rrdatas      = each.value  # Multiple IPs for each A record
}

###===================================================================================###
#                                   Outputs
###===================================================================================###

# Output the Managed Zone ID
output "managed_zone_id" {
  value = google_dns_managed_zone.vastclusters.id
}

# Output the nameservers associated with the managed DNS zone
output "name_servers" {
  value = google_dns_managed_zone.vastclusters.name_servers
}

# Output the names of all created A records
output "a_record_names" {
  value = [for record in google_dns_record_set.a_records : record.name]
}

# Output the IP addresses associated with the A records
output "a_record_ips" {
  value = [for record in google_dns_record_set.a_records : record.rrdatas]
}
###===================================================================================###
#
#  File:  dns1.terraform.tfvars
#  Created By: Karl Vietmeier
#
#  This creates A records for a reserved CIDR in GCP for VAST VIP addresses
#
###===================================================================================###

# terraform.tfvars
project_id      = "your-project-id"
region          = "us-west3"
zone            = "us-west3-a"

dns_name   = "your-domain.com."
description = "VIP Pool IPs"

networks = [
  "default",
  "your-vpc-name"
]

a_records = {
  "protocolvip1"   = ["your-ip-address"],
  "protocolvip2"   = ["your-ip-address"],
  "protocolvip3"   = ["your-ip-address"],
  "repvip1"        = ["your-ip-address"],
  "repvip2"        = ["your-ip-address"],
  "repvip3"        = ["your-ip-address"],
  "repvip4"        = ["your-ip-address"],
  "vastdata1" = [
    "Use IPs from the list above",
    "Use IPs from the list above",
    "Use IPs from the list above",
    "Use IPs from the list above"
  ]
}
###===================================================================================###
#
#  File:  variables.tf
#  Created By: Karl Vietmeier
#
#  Variable definitions with defaults
#
###===================================================================================###

# variables.tf
###--- Provider Info
variable "region" {
  description = "Region to deploy resources"
}

variable "zone" {
  description = "Availbility Zone"
}

variable "project_id" {
  description = "The ID of the Google Cloud project."
  type        = string
}

variable "dns_name" {
  description = "The DNS name for the managed zone."
  type        = string
}

variable "description" {
  description = "Description for the managed DNS zone."
  type        = string
}

variable "networks" {
  description = "A list of networks for private visibility."
  type        = list(string)
}


variable "a_records" {
  description = "A map of subdomains to lists of IP addresses."
  type        = map(list(string))
}

variable "vastcluser_dns" {
description = "DNS server on VAST cluster"
type = string

}#### License

``` text
SPDX-License-Identifier: Apache-2.0
```
### GCP DNS Forwarding Zone for a VAST Data Cluster

Provisions 1 or more **Cloud DNS private forwarding zones** in **Google Cloud Platform (GCP)**. It's used to forward DNS queries for **VAST Data Cluster** domains (e.g., `vastdata.com.`).

---

#### Notes

- [GCP: Private DNS Zones](https://cloud.google.com/dns/docs/zones#private)

#### Requirements

- Google Cloud Project with DNS API enabled
- Appropriate IAM permissions to create Cloud DNS zones
- Terraform v1.3+ and Google provider configured
- DNS confiogured on a VAST Cluster

---

#### Author/s

- **Karl Vietmeier**

#### License

This project is licensed under the Apache License - see the [LICENSE.md](LICENSE.md) file for details
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
###===================================================================================###
#
#  Created By: Karl Vietmeier
#
#  GCP Private DNS Forwarding Zone for VAST Data Cluster
#
#  Description:
#    Provisions a private DNS managed zone in Google Cloud and
#    configures it to forward DNS queries to a VAST Data cluster or other
#    external DNS resolver.
#
#    - Enables private DNS resolution across specified VPC networks
#    - Uses Cloud DNS forwarding to route queries to a specified target server
#
#  Use Case:
#    Integrating GCP-based workloads with DNS services provided by a VAST Data
#    cluster, enabling name resolution for applications that rely on external DNS.
#
###===================================================================================###

###===================================================================================###
#                                 Provider Configuration
###===================================================================================###
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

# Configure the Google Cloud provider with the project, region, and zone.
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}


###===================================================================================###
#                      Private DNS Managed Zone Configuration (Updated)
###===================================================================================###
resource "google_dns_managed_zone" "dns_forwarder" {
  # Use for_each to create a zone for every entry in the forwarding_zones map
  for_each = var.forwarding_zones

  # Define the DNS Managed Zone
  # The name must be unique; using the map key ensures this
  name        = each.key
  dns_name    = each.value.dns_name
  description = each.value.description
  visibility  = "private"

  # Configure private visibility for the DNS zone
  private_visibility_config {
    # Dynamically add networks from the `var.networks` variable
    dynamic "networks" {
      for_each = var.networks
      content {
        network_url = "https://www.googleapis.com/compute/v1/projects/${var.project_id}/global/networks/${networks.value}"
      }
    }
  }

  # Setup this domain up with a forwarder
  forwarding_config {
    target_name_servers {
      # Reference the target DNS IP from the map value
      ipv4_address    = each.value.vastcluser_dns
      # Retain the forwarding_path from the original code/variable if still used
      forwarding_path = try(each.value.forwarding_path, var.forwarding_path)
    }
  }
}

###===================================================================================###
#                                   Outputs (Updated)
###===================================================================================###
output "forwarding_zone_names" {
  description = "The list of names of the created DNS forwarding zones."
  # Use the splat expression to output the names of all created zones
  value = {
    for k, v in google_dns_managed_zone.dns_forwarder : k => v.dns_name
  }
}###===================================================================================###
#
#  File:  forwarder.variables.tf
#  Created By: Karl Vietmeier
#
#  Variable definitions with defaults
#
###===================================================================================###

# variables.tf
###--- Provider Info
variable "region" {
  description = "Region to deploy resources"
}

variable "zone" {
  description = "Availbility Zone"
}

variable "project_id" {
  description = "The ID of the Google Cloud project."
  type        = string
}

# Example of what your updated variables.tf should look like
variable "forwarding_zones" {
  description = "A map of forwarding zones to create. Key is the zone ID."
  type = map(object({
    dns_name          = string
    vastcluser_dns    = string # The IP of the target DNS server
    description       = string
    forwarding_path   = optional(string, "private") # Add as an optional if you want to keep it simple
  }))

}

# The existing variables like project_id, region, zone, and networks will still be needed.
# For simplicity, I'm assuming 'networks' will apply to *both* zones.
# Fixes the error: "Reference to undeclared input variable networks"
variable "networks" {
  description = "List of network names to bind the private DNS zone(s) to."
  type        = list(string)
}

# Fixes the error: "Reference to undeclared input variable forwarding_path"
# (Used as a fallback path in the 'try' function within the main.tf resource)
variable "forwarding_path" {
  description = "The service to use for the DNS forwarding, typically 'default' or 'private'."
  type        = string
  default     = "private"
}#### License

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
]#### License

``` text
SPDX-License-Identifier: Apache-2.0
```
### Create Default GCP Firewall Rules

Recreate the default GCP firewall rules

---

#### Notes

Put Notes Here

---

#### Author/s

* **Karl Vietmeier**

#### License

This project is licensed under the Apache License - see the [LICENSE.md](LICENSE.md) file for details

#### Acknowledgments

* None so far other than the many good examples out there.
###===================================================================================###
#
#  File:  fw_defaults.main.tf
#  Created By: Karl Vietmeier
#
#  Purpose:  Create default GCP Firewall rules
# 
#  Files in Module:
#    main.tf
#    variables.tf
#    variables.tfvars
#
###===================================================================================###

/* 
  
Usage:
terraform plan -var-file=".\fw_defaults.tfvars"
terraform apply --auto-approve -var-file=".\fw_defaults.tfvars"
terraform destroy --auto-approve -var-file=".\fw_defaults.tfvars"

*/

###===================================================================================###
#     Start creating infrastructure resources
###===================================================================================###

resource "google_compute_firewall" "default_allow_internal" {
  name    = "default-allow-internal"
  network = "default"

  direction = "INGRESS"
  priority  = 65534

  source_ranges = ["10.0.0.0/8", "192.168.0.0/16", "172.16.0.0/12"]

  allow {
    protocol = "all"
  }
}

resource "google_compute_firewall" "default_allow_ssh" {
  name    = "default-allow-ssh"
  network = "default"

  direction = "INGRESS"
  priority  = 65534

  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_firewall" "default_allow_rdp" {
  name    = "default-allow-rdp"
  network = "default"

  direction = "INGRESS"
  priority  = 65534

  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }
}

resource "google_compute_firewall" "default_allow_icmp" {
  name    = "default-allow-icmp"
  network = "default"

  direction = "INGRESS"
  priority  = 65534

  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "icmp"
  }
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
  required_providers {
  google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

# Set these vars
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}###===================================================================================###
#
#  File:  terraform.tfvars
#  Created By: Karl Vietmeier
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


###---  Standard Values
# Project Info
project_id      = "<project ID>"
region          = "us-west2"
zone            = "us-west2-a"

# VPC Config
vpc_name        = "default"
###===================================================================================###
#
#  File:  variables.tf
#  Created By: Karl Vietmeier
#
#  Variable definitions with defaults
#
###===================================================================================###


###--- Provider Info
variable "region" {
  description = "Region to deploy resources"
}

variable "zone" {
  description = "Availbility Zone"
}

variable "project_id" {
  description = "GCP Project ID"
}


###--- VPC Setup
variable "vpc_name" {
  description = "Name of VPC"
  type        = string
  default     = "default"
}
#### License

``` text
SPDX-License-Identifier: Apache-2.0
```
###  GKE Cluster

Description

---

#### Notes

APIs:
You need these APIs enabled:

* Kubernetes Engine - container.googleapis.com
* IAM - iam.googleapis.com
* Storage - storage.googleapis.com

---

#### My code is Built With

* [Visual Studio Code](https://code.visualstudio.com/) - Editor
* [Terraform](https://www.terraform.io/) - Terraform

#### All run under PowerShell on Windows 11

* [Windows Terminal](https://docs.microsoft.com/en-us/windows/terminal/) - Console

#### Author/s

* **Karl Vietmeier**

#### License

This project is licensed under the Apache License - see the [LICENSE.md](LICENSE.md) file for details

#### Acknowledgments

* None so far other than the many good examples out there.
###===================================================================================###
#
#  File:  iam.tf
#  Created By: Karl Vietmeier
#
#  Terraform Module Code
#  Purpose:  Blank Template for extra resources
# 
###===================================================================================###


###===================================================================================###
#     Start creating resources
###===================================================================================###

# Google Cloud Service Account for GKE to access GCS
resource "google_service_account" "gke_gcs_access_sa" {
  account_id   = "gke-gcs-access-sa"
  display_name = "GKE Service Account for GCS Access"
  project      = var.project_id
}

# Grant the Service Account the necessary permissions to access the GCS bucket
resource "google_project_iam_member" "gke_gcs_access_sa_storage_bucket_access" {
  project = var.project_id
  role    = "roles/storage.objectAdmin" # Or roles/storage.objectViewer, roles/storage.objectCreator, etc.
  member  = "serviceAccount:${google_service_account.gke_gcs_access_sa.email}"
}
###===================================================================================###
#
#  File:  gke.main.tf
#  Created By: Karl Vietmeier
#
#  Terraform Module Code
#  Purpose:  Create a basic GKE Cluster  
# 
###===================================================================================###

data "google_container_engine_versions" "gke_version" {
  location = var.region
  version_prefix = "1.27."
}

###===================================================================================###
#     Start creating infrastructure resources
###===================================================================================###

# GKE Cluster
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.region
  project  = var.project_id

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  # Optional: Network configuration
  network    = var.vpc_name
  subnetwork = var.subnet_name
}

# Separately Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name       = google_container_cluster.primary.name
  location   = var.region
  cluster    = google_container_cluster.primary.name
  
  version    = data.google_container_engine_versions.gke_version.release_channel_default_version["STABLE"]
  node_count = var.gke_num_nodes

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = var.project_id
    }

    # preemptible  = true
    machine_type = "n1-standard-1"
    tags         = ["gke-node", "${var.project_id}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}
###===================================================================================###
#
#  File:  iam.tf
#  Created By: Karl Vietmeier
#
#  Terraform Module Code
#  Purpose:  Blank Template for extra resources
# 
###===================================================================================###


# Output the cluster name for easy access
output "cluster_name" {
  value       = google_container_cluster.primary.name
  description = "The name of the GKE cluster."
}

# Output the cluster location
output "cluster_location" {
  value       = google_container_cluster.primary.location
  description = "The location of the GKE cluster."
}

# Output kubeconfig instructions
output "kubeconfig_instructions" {
  value = "To connect to your cluster, run: gcloud container clusters get-credentials ${google_container_cluster.primary.name} --region ${google_container_cluster.primary.location} --project ${var.project_id}"
  description = "Instructions to configure kubectl for the GKE cluster."
}

output "gke_gcs_access_sa_email" {
  value       = google_service_account.gke_gcs_access_sa.email
  description = "Email of the GSA for GKE GCS access."
}###===================================================================================###
#
#  File:  provider.tf
#  Created By: Karl Vietmeier
#
#  Purpose: Configure the GCP TerraForm Provider 
# 
###===================================================================================###


terraform {
  required_providers {
  google = {
      source  = "hashicorp/google"
      version = "4.74.0"
    }
  }
}

# Set these vars
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}###===================================================================================###
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


###---  Standard Values
# Project Info
project_id      = "clouddev-itdesk124"
region          = "us-west2"
zone            = "us-west2-a"

# VPC Config
vpc_name        = "karlv-corevpc"
subnet_name     = "subnet-hub-us-west2"


###======  Examples:
cluster_name  = "gketesting01"
gke_num_nodes = 2###===================================================================================###
#
#  File:  variables.tf
#  Created By: Karl Vietmeier
#
#  Variable definitions with defaults
#
###===================================================================================###


### Provider Settings
variable "region" {
  description = "Region to deploy resources"
}

variable "zone" {
  description = "Availbility Zone"
}

variable "project_id" {
  description = "GCP Project ID"
}

variable "vpc_name" {
  description = "VPC to use"
  default     = "default"
}

variable "subnet_name" {
  description = "Subnet to use"
  default     = "default"
}

### GKE Cluster Vars
variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
  default     = "gcs-gke-cluster"
}

variable "gke_username" {
  default     = ""
  description = "gke username"
}

variable "gke_password" {
  default     = ""
  description = "gke password"
}

variable "gke_num_nodes" {
  default     = 2
  description = "number of gke nodes"
}
###===================================================================================###
#
#  File:  Template.tf
#  Created By: Karl Vietmeier
#
#  Terraform Module Code
#  Purpose:  Create a VM
#            With basic settings
# 
#  Files in Module:
#    main.tf
#    variables.tf
#    variables.tfvars
#
#  Usage:
#  terraform apply --auto-approve
#  terraform destroy --auto-approve
###===================================================================================###

/* 

Put Usage Documentation here

*/


###===================================================================================###
#     Start creating infrastructure resources
###===================================================================================###

# Setup cloud-init
data "cloudinit_config" "conf" {
  gzip = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content = file("../../secrets/cloud-init-dnfbased.default.yaml")
    filename = "conf.yaml"
  }
}

# Reserve a specific static external (public) IP address
resource "google_compute_address" "my_public_ip" {
  name         = "karlv-public-ip"
  address_type = "EXTERNAL"
  region       = var.region
}

resource "google_compute_address" "my_private_ip" {
  name         = "karlv-private-ip"
  address_type = "INTERNAL"
  subnetwork   = var.subnet_name
  region       = var.region
  address      = "10.111.1.4" # Replace with your desired static private IP
}

# Google Cloud VM instance with public IP
resource "google_compute_instance" "vm_instance" {
  zone         = var.zone             # Use the zone variable
  name         = var.vm_name          # Use the vm_name variable
  machine_type = var.machine_type     # Use the machine_type variable

  boot_disk {
    initialize_params {
      image    = var.os_image  # Replace with your preferred image
      size     = var.bootdisk_size
    }
  }

  # Configure the network interface with the specified private and public IPs
  network_interface {
    subnetwork    = var.subnet_name
    network_ip    = google_compute_address.my_private_ip.address  # Specified static private IP

    access_config {                         # Enables a public IP address
      nat_ip = google_compute_address.my_public_ip.address       # Specified static public IP
    }
  }

  metadata = {
    #user-data          = "${data.cloudinit_config.conf.rendered}"
    #ssh-keys           = "${var.ssh_user}:${local.ssh_key_content}"
    ssh-keys           = "${file(var.ssh_key_file)}"
    serial-port-enable = true # Enable serial port access for debugging
  }

  tags = ["kv-linux", "kv-infra"]
}


# Output the IP addresses
output "instance_public_ip" {
  value = google_compute_address.my_public_ip.address
}

output "instance_private_ip" {
  value = google_compute_address.my_private_ip.address
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
  required_providers {
  google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}###===================================================================================###
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

# Project Info
project_id      = "mygcpproject"
region          = "us-west2"
zone            = "us-west2-a"

# VM Info
vm_name         = "linux01"
machine_type    = "e2-medium"
os_image        = "centos-stream-9-v20241009"
bootdisk_size   = "200"
ssh_key_file    = "../../../somedir/foo.bar"
ssh_user        = "karlv"

# VPC Config - existing
vpc_name        = "default"
subnet_name     = "default"###===================================================================================###
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

# Project Info
project_id      = "clouddev-itdesk124"
region          = "us-west2"
zone            = "us-west2-a"

# VM Info
vm_name         = "linuxtools"
machine_type    = "e2-medium"
os_image        = "centos-stream-9-v20241009"
bootdisk_size   = "200"
ssh_key_file    = "../../../../secrets/ssh_keys.txt"
ssh_user        = "karlv"

# VPC Config - existing
vpc_name        = "default"
subnet_name     = "infrasubnet01"###===================================================================================###
#
#  File:  variables.tf
#  Created By: Karl Vietmeier
#
#  Variable definitions with defaults
#
###===================================================================================###

# Project ID
variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

# Region
variable "region" {
  description = "The GCP region to deploy resources"
  type        = string
}

# Zone
variable "zone" {
  description = "The GCP zone to deploy the VM"
  type        = string
}


###--- VM Info
# Machine type for the VM
variable "machine_type" {
  description = "The machine type for the VM"
  type        = string
  default     = "e2-medium"
}

# VM instance name
variable "vm_name" {
  description = "Name of the VM instance"
  type        = string
  default     = "my-vm"
}

variable "os_image" {
  description = "OS Image to use"
  type        = string
  default     = "centos-stream-9-v20241009"
}

variable "bootdisk_size" {
  description = "Size of boot disk in GB"
  type        = string
  default     = "40"
}

###--- VM Metadata
# SSH 
variable "ssh_user" {
  description = "User to SSH in as"
  type        = string
}

variable "ssh_key_file" {
  description = "Path to the SSH public key file"
  type        = string
}


###--- Network

# Network name
variable "vpc_name" {
  description = "The name of the VPC network"
  type        = string
  default     = "custom-network"
}

# Subnet name
variable "subnet_name" {
  description = "The name of the subnetwork"
  type        = string
  default     = "custom-subnet"
}

# Subnet CIDR range
variable "subnet_cidr" {
  description = "CIDR range for the subnet"
  type        = string
  default     = "10.0.0.0/24"
}

###=================          Locals                ==================###

# Read the SSH public key
#locals {
#  ssh_key_content = file(var.ssh_key_file)
#}

#### License

``` text
SPDX-License-Identifier: Apache-2.0
```
### Create NAT Gateways

You need a NAT Gateway and router in every region you have subnets  
This module creates gateways using the "regions()" list

---

#### Notes

Put Notes Here

---

#### Author/s

* **Karl Vietmeier**

#### License

This project is licensed under the Apache License 

#### Acknowledgments

* None so far other than the many good examples out there.
###===================================================================================###
#                      SPDX-License-Identifier: Apache-2.0
###===================================================================================###
#
#  File:  natgw.main.tf
#  Created By: Karl Vietmeier
#
#  Purpose: Create NAT Gateways in multiple regions
#
#  Put it all in one file to keep it simple.
# 
#  Files in Module:
#    natgw.main.tf
#    natgw.tfvars
#
###===================================================================================###

###===================================================================================###
#     Provider
###===================================================================================###

terraform {
  required_providers {
  google = {
      source  = "hashicorp/google"
      #version = "4.51.0"
      version = "~> 6.0.0"

    }
  }
}

# Set these vars
provider "google" {
  project = var.project_id
  region  = var.default_region
  zone    = var.default_zone
}

###===================================================================================###
#     Variables
###===================================================================================###

###--- Provider Info
variable "default_region" {
  description = "Region to deploy resources"
}

variable "default_zone" {
  description = "Availbility Zone"
}

variable "project_id" {
  description = "GCP Project ID"
}


###--- VPC Setup
variable "vpc_name" {
  description = "Name of VPC"
  type        = string
  default     = "default"
}


# Define a list variable for the regions
variable "regions" {
  type = list(string)
}


###===================================================================================###
#     Create infrastructure resources
###===================================================================================###

# Create a router for the GWs in each region.
resource "google_compute_router" "gw_router" {
  for_each = toset(var.regions)

  name    = "gw-router-${each.key}"
  region  = each.key
  network = var.vpc_name
}

# Create NAT Gateways for each region
resource "google_compute_router_nat" "nat" {
  for_each = toset(var.regions)

  name                                = "nat-${each.key}"
  router                              = google_compute_router.gw_router[each.key].name
  region                              = each.key
  nat_ip_allocate_option              = "AUTO_ONLY"                       # Use auto-allocated IPs for NAT
  source_subnetwork_ip_ranges_to_nat  = "ALL_SUBNETWORKS_ALL_IP_RANGES"   # Allow all subnets in the region
  
  auto_network_tier   = "STANDARD"

  # Disable Endpoint Independent Mapping
  enable_endpoint_independent_mapping = false

  # Optional logging configuration
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
###===================================================================================###
#
#  File:  natgw.tfvars
#  Created By: Karl Vietmeier
#
###===================================================================================###


# Project Info
project_id      = "clouddev-itdesk124"
default_region  = "us-west2"
default_zone    = "us-west2-a"

# VPC Config
vpc_name        = "default"

# Region List
regions = [ "us-west1",
            "us-east1", 
            "us-east4", 
            "us-central1", 
            "europe-west1",
            "asia-east1", 
            "asia-east2" 
]

### Curent regions:
/*
africa-south1      
asia-east1         
asia-east2        
asia-northeast1  
asia-northeast2 
asia-northeast3
asia-south1   
asia-south2  
asia-southeast1
asia-southeast2         
australia-southeast1   
australia-southeast2  
europe-central2      
europe-north1 
europe-southwest1  
europe-west1      
europe-west10    
europe-west12   
europe-west2   
europe-west3  
europe-west4 
europe-west6
europe-west8    
europe-west9   
me-central1   
me-central2  
me-west1    
northamerica-northeast1  
northamerica-northeast2  
northamerica-south1     
southamerica-east1     
southamerica-west1    
us-central1             
us-east1               
us-east4              
us-east5             
us-south1           
us-west1           
us-west2          
us-west3         
us-west4        
*/###===================================================================================###
#
#  File:  natgw.tfvars.txt
#  Created By: Karl Vietmeier
#
###===================================================================================###


# Project Info
project_id      = "project_id"
default_region  = "us-west3"
default_zone    = "us-west3-a"

# VPC Config
vpc_name        = "default"

# Region List
regions = [ "us-west3",
            "asia-east2" 
]

### Regions:
africa-south1      
asia-east1         
asia-east2        
asia-northeast1  
asia-northeast2 
asia-northeast3
asia-south1   
asia-south2  
asia-southeast1
asia-southeast2         
australia-southeast1   
australia-southeast2  
europe-central2      
europe-north1 
europe-southwest1  
europe-west1      
europe-west10    
europe-west12   
europe-west2   
europe-west3  
europe-west4 
europe-west6
europe-west8    
europe-west9   
me-central1   
me-central2  
me-west1    
northamerica-northeast1  
northamerica-northeast2  
northamerica-south1     
southamerica-east1     
southamerica-west1    
us-central1             
us-east1               
us-east4              
us-east5             
us-south1           
us-west1           
us-west2          
us-west3         
us-west4        # Install the Active Directory Domain Services (AD DS) role
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# Import the ADDSDeployment module
Import-Module ADDSDeployment

# Promote the server to a Domain Controller
Install-ADDSForest -DomainName "ginaz.org" `
    -DomainNetbiosName "ginaz" `
    -InstallDns:$true `
    -NoRebootOnCompletion:$false `
    -SafeModeAdministratorPassword (ConvertTo-SecureString -String "Chalc0pyr1te!123" -AsPlainText -Force)

# Reboot the system if necessary
Restart-Computer

# Create a new Organizational Unit (OU)
New-ADOrganizationalUnit -Name "VAST" -Path "DC=ginaz,DC=org"

# Redirect new computer accounts to the new OU
redircmp "OU=VAST,DC=ginaz,DC=org"

# Move existing computer accounts if needed
Get-ADComputer -SearchBase "CN=Computers,DC=ginaz,DC=org" -Filter * |
ForEach-Object {
    Move-ADObject -Identity $_.DistinguishedName -TargetPath "OU=Workstations,DC=ginaz,DC=org"
}

# Enable Remote Desktop for local Administrator login
# Ensure that RDP is enabled
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\' -Name 'fDenyTSConnections' -Value 0

# Enable the local Administrator account
Enable-LocalUser -Name "Administrator"

# Add the local Administrator account to the "Remote Desktop Users" group
Add-LocalGroupMember -Group "Remote Desktop Users" -Member "Administrator"

# Set the Administrator password
$password = ConvertTo-SecureString "Chalc0pyr1te!123" -AsPlainText -Force
Set-LocalUser -Name "Administrator" -Password $password###===================================================================================###
#
#  File:  Template.tf
#  Created By: Karl Vietmeier
#
#  Terraform Module Code
#  Purpose:  Create a Windows Server VM for Infrastructure
# 
###===================================================================================###

/* 

Put Usage Documentation here

*/


###===================================================================================###
#     Start creating infrastructure resources
###===================================================================================###

# Reserve a specific static external (public) IP address
resource "google_compute_address" "vm_public_ip" {
  name         = var.public_ip_name
  address_type = "EXTERNAL"
  region       = var.region
}

resource "google_compute_address" "vm_private_ip" {
  name         = var.private_ip_name
  address_type = "INTERNAL"
  subnetwork   = var.subnet_name
  region       = var.region
  address      = var.private_ip
}


#
###=================   Create VM instance with public IP   ===================###
#
resource "google_compute_instance" "vm_instance" {
  zone         = var.zone             # Use the zone variable
  name         = var.vm_name          # Use the vm_name variable
  machine_type = var.machine_type     # Use the machine_type variable

  boot_disk {
    initialize_params {
      image    = var.os_image         # Replace with your preferred image
      size     = var.bootdisk_size
    }
  }

  # Configure the network interface with the specified private and public IPs
  network_interface {
    subnetwork    = var.subnet_name
    network_ip    = google_compute_address.vm_private_ip.address  # Specified static private IP
    
    # Enables a public IP address
    access_config {
      # Specified static public IP
      nat_ip = google_compute_address.vm_public_ip.address
    }
  }

  metadata = {
    
    # Set the Timezone
    #"user-data" = <<EOF
    #powershell -Command "tzutil /s 'Pacific Standard Time'" 
    #EOF
    
    # Windows post install config
    enable-windows-automatic-updates    = "true"
    sysprep-specialize-script-ps1       = "${file(var.windows-sysprep-script)}"
  }

  tags = var.vm_tags
  
  service_account {
    # Google recommends custom service accounts with `cloud-platform` scope with
    # specific permissions granted via IAM Roles.
    email  = var.sa_email
    scopes = var.sa_scopes
  }
}
#
###===================       End VM Resource Block       ===================###
#


###===================   Outputs  ===================###

# Output the public IP address
output "public_ip" {
  value       = google_compute_address.vm_public_ip.address
  description = "Reserved public IP address for the VM"
}

# Output the private IP address
output "private_ip" {
  value = google_compute_instance.vm_instance.network_interface[0].network_ip
  description = "The private IP address of the VM instance."
}###===================================================================================###
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
  required_providers {
  google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}###===================================================================================###
#
#  File:  submodule.tf
#  Created By: Karl Vietmeier
#
#  Terraform Module Code
#  Purpose:  Blank Template for extra resources
# 
###===================================================================================###

/* 

Put Usage Documentation here

*/


###===================================================================================###
#     Start creating resources
###===================================================================================######===================================================================================###
#
#  File: winserver2201.terraform.tfvars
#  Created By: Karl Vietmeier
#
#  This file should be excluded from your github repo
#
###===================================================================================###

# Project Info
project_id      = "clouddev-itdesk124"
region          = "us-west2"
zone            = "us-west2-b"

# Service Account/s
sa_email        = "913067105288-compute@developer.gserviceaccount.com"
sa_scopes       = ["cloud-platform"]

# VM Info
private_ip      = "172.20.16.3"
public_ip_name  = "w22server01-public-ip"
private_ip_name = "w22server01-private-ip"
vm_name         = "w22server01"
machine_type    = "c2-standard-4"
os_image        = "windows-server-2022-dc-v20241115"
bootdisk_size   = "400"
vm_tags         = [ "karlv-vms", "karlv-windows", "karlv-infra" ]
windows-sysprep-script = "../../../scripts/windows-sysprep-config.ps1"

# VPC Config - existing
vpc_name        = "karlv-corevpc"
subnet_name     = "subnet-hub-us-west2"
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

project_id = "your-project-id"
source_ip  = "<my_ip>"


###======  Examples (Azure):
###======================== Define values for the complex variables  =======================###
# Storage Account configurations
storage_account_configs = [
  {
    name         = "files"
    acct_kind    = "FileStorage" # Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2.
    account_tier = "Premium"     # If "Premium" - it must be in a "FileStorage" Storage Account
    access_temp  = "Hot"
    replication  = "LRS"
  },
  {
    name         = "blobs"
    acct_kind    = "BlobStorage" # Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2.
    account_tier = "Standard"    # 
    access_temp  = "Hot"
    replication  = "LRS"
  }
]

#- Fileshares using complex object syntax
shares = [
  {
    name  = "volume01",
    quota = "100"
  },
  {
    name  = "volume02",
    quota = "150"
  },
  {
    name  = "volume03",
    quota = "200"
  }
]

### - List/map of multiple shares - using simple map
file_shares = {
  "volume01" = "100",
  "volume02" = "100",
  "volume03" = "250"
}###===================================================================================###
#
#  File:  variables.tf
#  Created By: Karl Vietmeier
#
#  Variable definitions with defaults
#
###===================================================================================###

# Project ID
variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

# Region
variable "region" {
  description = "The GCP region to deploy resources"
  type        = string
}

# Zone
variable "zone" {
  description = "The GCP zone to deploy the VM"
  type        = string
}

# Service Account
variable "sa_email" {
  description = "Service Account email"
  type        = string
}

variable "sa_scopes" {
  description = "Scope for Service Account"
  type        = list(string)
}


###--- VM Info
# Machine type for the VM
variable "machine_type" {
  description = "The machine type for the VM"
  type        = string
  default     = "e2-medium"
}

# VM instance name
variable "vm_name" {
  description = "Name of the VM instance"
  type        = string
  default     = "my-vm"
}

variable "os_image" {
  description = "OS Image to use"
  type        = string
  default     = "windows-server-2022-dc-v20241115"
}

variable "bootdisk_size" {
  description = "Size of boot disk in GB"
  type        = string
  default     = "150"
}

###--- VM Metadata
variable "windows-sysprep-script" {
  description = "Windows config script"
  type        = string
}

variable vm_tags {
  description = "Tags"
  type        = list(string)
}


###--- Network

# Network name
variable "vpc_name" {
  description = "The name of the VPC network"
  type        = string
  default     = "default"
}

# Subnet name
variable "subnet_name" {
  description = "The name of the subnetwork"
  type        = string
  default     = "default"
}

variable "public_ip_name" {
  description = "Name for Private IP"
  type        = string
  default     = "karlv-pubip"
}

variable "private_ip_name" {
  description = "Name for Public IP"
  type        = string
}

variable "private_ip" {
  description = "Static Private IP"
  type        = string
}

/*
# Subnet CIDR range
variable "subnet_cidr" {
  description = "CIDR range for the subnet"
  type        = string
  default     = "10.0.0.0/24"
}
*/

###=================          Locals                ==================###


# cloud-init file
locals {
  windows-sysprep = file(var.windows-sysprep-script)
}


## Custom VPC Infrastructure with NAT Gateways and Cloud Routers

This Terraform module provisions a custom Virtual Private Cloud (VPC) in Google Cloud Platform (GCP) with the following components:

- A named custom VPC with manual subnet creation
- Subnets across multiple GCP regions
- Optional secondary IP ranges (e.g., for services like GKE or VAST)
- IPv6 dual-stack support (where enabled)
- Private Google access on all subnets
- Cloud Routers and Cloud NAT (in user-specified regions)
- VPC Peering for Private Service Access (used by Cloud SQL, Memorystore, etc.)

---

### Subnet Configuration

Dynamically creates subnets from var.subnets.
Supports:

- region: GCP region
- name: Subnet name
- private_ip_google_access: true/false
- ip_cidr_range: Primary IPv4 CIDR block
- ipv6_cidr_range (optional): IPv6 block (for dual-stack subnets)
- secondary_ip_ranges (optional): Additional named secondary CIDR blocks (e.g., for services)

### Requirements

- Terraform ≥ 1.4
- Google Cloud Provider ≥ 5.9
- **Google Beta Provider for ipv6 EULA**
- Enabled APIs: compute.googleapis.com, servicenetworking.googleapis.com

---

### Terraform Resource References

- [compute_network](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network)
- [compute_subnetwork](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork)
- [compute_router](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router)
- [compute_router_nat](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat)
- [compute_network_ipv6_ula_allocation](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_ipv6_ula_allocation)
- [compute_global_adress](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_adress)
- [service_networking_connection](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_networking_connection)
- [project_service](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service)

---

**Author:** Karl Vietmeier  

---

### Usage

Run the following Terraform commands with your custom variable file:

```bash
terraform plan -var-file=".\corevpc.terraform.tfvars"
terraform apply --auto-approve -var-file=".\corevpc.terraform.tfvars"
terraform destroy --auto-approve -var-file=".\corevpc.terraform.tfvars"
```
###===================================================================================###
#  VPC Infrastructure Configuration
#
#  - Creates a custom VPC with subnets and secondary IP ranges
#  - Enables IPv6 support where applicable
#  - Sets up Private Service Access for Google-managed services
#  - Deploys Cloud Routers and NAT Gateways in specified regions
#  - Establishes VPC peering with the Service Networking API
#
#  NOTE: Only the associated *.tfvars file should be modified to customize this setup.
#
#  Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network
#  Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork
#  Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router
#  Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat
#  Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_ipv6_ula_allocation
#  Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address
#  Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_networking_connection
#  Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service
#
#  Requires the Google and Google-Beta providers for setting up EULA IPv6.
#  Ensure the Google Cloud project has the "Service Networking API" enabled.
#  Ensure the user has sufficient permissions to create VPCs, subnets, routers, and NAT gateways.
#
###===================================================================================###

###===================================================================================###
#                          Start creating infrastructure resources
###===================================================================================###


locals {
  unique_regions = distinct([for subnet in var.subnets : subnet.region])
}


###===================================================================================###
#                           Private Service Access Peering Setup
###===================================================================================###

# --- VPC Configuration ---
# Need the beta provider to enable IPv6 ULA
resource "google_compute_network" "custom_vpc" {
  provider                 = google-beta
  project                  = var.project_id
  name                     = var.vpc_name
  auto_create_subnetworks  = false
  enable_ula_internal_ipv6 = true  # REQUIRED to use INTERNAL IPv6 in subnets
  routing_mode             = "GLOBAL"   
}

# Reserve IP range for Private Service Access (used by Cloud SQL, Memorystore, etc.)
resource "google_compute_global_address" "private_service_range" {
  name          = "private-service-access"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.custom_vpc.self_link
  address       = null  # Auto-assigned by GCP
}

# Enable the Service Networking API
resource "google_project_service" "servicenetworking" {
  project = var.project_id
  service = "servicenetworking.googleapis.com"
}


/*
# Doesn't work yet 
resource "google_compute_network_ipv6_ula_allocation" "custom_vpc_ula" {
  network = google_compute_network.custom_vpc.name
}
*/

# --- Subnets with Private Google Access ---
resource "google_compute_subnetwork" "subnets" {
  for_each = { for subnet in var.subnets : subnet.name => subnet }

  name                     = each.value.name
  region                   = each.value.region
  ip_cidr_range            = each.value.ip_cidr_range
  network                  = google_compute_network.custom_vpc.id
  private_ip_google_access = true
  
  # Enable internal IPv6 if name ends in "ipv6"
  stack_type        = can(regex("ipv6$", each.value.name)) ? "IPV4_IPV6" : "IPV4_ONLY"
  ipv6_access_type  = can(regex("ipv6$", each.value.name)) ? "INTERNAL" : null
  
  # If there are secondary IP ranges configured for the subnet, create them.
  dynamic "secondary_ip_range" {
    for_each = try(
      [for r in each.value.secondary_ip_ranges : r if r != null],
      []
    )
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }

}

# --- Routers per Region (only if NAT is enabled) ---
resource "google_compute_router" "routers" {
  for_each = { for region in local.unique_regions : region => region if contains(var.nat_enabled_regions, region) }
  name     = "router-${each.key}"
  network  = google_compute_network.custom_vpc.id
  region   = each.key
}

# --- NAT Gateways per Region ---
resource "google_compute_router_nat" "nats" {
  for_each                           = google_compute_router.routers
  name                               = "nat-${each.key}"
  router                             = each.value.name
  region                             = each.key
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  # Avoid potential race condition  
  depends_on = [
      google_compute_router.routers
  ]

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Create the VPC peering with service networking
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.custom_vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_service_range.name]

  depends_on = [
    google_project_service.servicenetworking
  ]
}


###===================================================================================###
#                                    Outputs
###===================================================================================###
output "nat_enabled_regions" {
  description = "List of regions where Cloud NAT is enabled"
  value       = var.nat_enabled_regions
}

output "subnet_cidrs" {
  description = "List of CIDR blocks for the subnets"
  value       = [for subnet in var.subnets : subnet.ip_cidr_range]
}

output "service_networking_connection" {
  description = "Peering connection to servicenetworking.googleapis.com"
  value       = google_service_networking_connection.private_vpc_connection.network
}



/*

resource "google_compute_global_address" "private_service_range" {
  name          = "private-service-access"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.custom_vpc.self_link
  
  # We use 192.168.0.0/16 for Cloud SQL.
  # It is distinct from 10.x (Voc) and 172.20.x (Hubs).
  address       = "192.168.0.0" 
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.custom_vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_service_range.name]
  depends_on              = [google_project_service.servicenetworking]
}
*/###===================================================================================###
#                                  Provider Configuration
###===================================================================================###
terraform {
  backend "gcs" {
    bucket  = "clouddev-itdesk124-tfstate"
    prefix  = "terraform/state/core-vpc"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.9.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 5.9.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}
###========================================================================================###
##  VPC Configuration Overview
##
##  - Configures a custom VPC and defines multiple subnets across regions
##  - Assigns primary and secondary IP ranges to subnets
##  - Enables IPv6 addressing for select subnets
##  - Specifies regions where NAT Gateways are deployed
##
##  NOTE: Only the associated *.tfvars file should be edited to customize this configuration.
###========================================================================================###

## Project Info
project_id      = "clouddev-itdesk124"
region          = "us-west3"
zone            = "us-west3-a"

default_region = "us-west3"
vpc_name       = "karlv-corevpc"
###========================================================================================###
##  Variable Definitions for VPC Infrastructure Deployment
##
##  - Defines input variables for region, zone, project ID, and VPC settings
##  - Includes subnet configuration with optional IPv6 and secondary ranges
##  - Specifies regions where Cloud NAT should be enabled
##
##  These variables are used across modules to provision a custom network topology.
###========================================================================================###

###--- Provider Info
variable "region" {
  description = "Region to deploy resources"
}

variable "zone" {
  description = "Availbility Zone"
}

variable "project_id" {
  description = "GCP Project ID"
}

# --- VPC Settings ---
variable "default_region" {
  description = "Default region"
  type        = string
  default     = "us-west2"
}

variable "vpc_name" {
  description = "Name of the custom VPC"
  type        = string
  default     = "custom-vpc"
}

# --- Subnet Definitions ---
/* 
List of subnet definitions. Each entry includes:
- name: Subnet name
- region: GCP region
- ip_cidr_range: Primary IPv4 CIDR block
- ipv6_cidr_range (optional): IPv6 block (for dual-stack subnets)
- secondary_ip_ranges (optional): Additional named secondary CIDR blocks (e.g., for services)
*/
variable "subnets" {
  description = "List of subnets with name, region, CIDR, and secondary cidr ranges"
  type = list(object({
    name                = string
    region              = string
    ip_cidr_range       = string
    ipv6_cidr_range     = optional(string)
    secondary_ip_ranges = optional(list(object({
      range_name    = string
      ip_cidr_range = string
    })))
  }))
}

# --- Cloud NAT Configuration ---
variable "nat_enabled_regions" {
  description = "List of regions to deploy Cloud NAT"
  type        = list(string)
  default     = []
}###========================================================================================###
##  VPC Configuration Overview
##
##  - Configures a custom VPC and defines multiple subnets across regions
##  - Assigns primary and secondary IP ranges to subnets
##  - Enables IPv6 addressing for select subnets
##  - Specifies regions where NAT Gateways are deployed
##
##  NOTE: Only the associated *.tfvars file should be edited to customize this configuration.
###========================================================================================###


### Real from gcloud - 
subnets = [
  # --- US CENTRAL ---
  { name = "subnet-hub-us-central1",      region = "us-central1",      ip_cidr_range = "172.20.64.0/20" },
  { name = "subnet-hub-us-central1-voc1", region = "us-central1",      ip_cidr_range = "172.9.1.0/24" },
  { name = "subnet-hub-us-central1-voc2", region = "us-central1",      ip_cidr_range = "172.11.1.0/24" },

  # --- US WEST ---
  { name = "subnet-hub-us-west1-01",      region = "us-west1",        ip_cidr_range = "172.20.0.0/20" },
  { name = "subnet-hub-us-west1-voc1",    region = "us-west1",        ip_cidr_range = "172.10.1.0/24" },
  { name = "subnet-hub-us-west1-voc2",    region = "us-west1",        ip_cidr_range = "172.10.2.0/24" },
  { name = "subnet-hub-us-west1-voc3",    region = "us-west1",        ip_cidr_range = "172.10.3.0/24" },
  { name = "subnet-hub-us-west1-voc4",    region = "us-west1",        ip_cidr_range = "172.10.4.0/24" },
  { name = "subnet-hub-us-west2",         region = "us-west2",        ip_cidr_range = "172.20.16.0/20" },
  { name = "subnet-hub-us-west2-02",      region = "us-west2",        ip_cidr_range = "172.21.128.0/20" },
  { name = "subnet-hub-us-west2-03",      region = "us-west2",        ip_cidr_range = "172.21.144.0/20" },
  { name = "subnet-hub-us-west2-voc1",    region = "us-west2",        ip_cidr_range = "172.5.1.0/24" },
  { name = "subnet-hub-us-west2-voc2",    region = "us-west2",        ip_cidr_range = "172.6.1.0/24" },
  { name = "subnet-hub-us-west2-voc3",    region = "us-west2",        ip_cidr_range = "172.7.1.0/24" },
  { name = "subnet-hub-us-west2-voc4",    region = "us-west2",        ip_cidr_range = "172.8.1.0/24" },
  { name = "subnet-hub-us-west2-ipv6",    region = "us-west2",        ip_cidr_range = "192.20.16.0/20" },
  { name = "subnet-hub-us-west3",         region = "us-west3",        ip_cidr_range = "172.20.32.0/20" },
  { name = "subnet-hub-us-west4",         region = "us-west4",        ip_cidr_range = "172.20.48.0/20" },

  # --- US EAST & SOUTH ---
  { name = "subnet-hub-us-east1",         region = "us-east1",        ip_cidr_range = "172.20.96.0/20" },
  { name = "subnet-hub-us-east1-voc1",    region = "us-east1",        ip_cidr_range = "172.10.5.0/24" },
  { name = "subnet-hub-us-east1-voc2",    region = "us-east1",        ip_cidr_range = "172.10.6.0/24" },
  { name = "subnet-hub-us-east1-voc3",    region = "us-east1",        ip_cidr_range = "172.10.7.0/24" },
  { name = "subnet-hub-us-east1-voc4",    region = "us-east1",        ip_cidr_range = "172.10.8.0/24" },
  { name = "subnet-hub-us-east4",         region = "us-east4",        ip_cidr_range = "172.20.112.0/20" },
  { name = "subnet-hub-us-east5",         region = "us-east5",        ip_cidr_range = "172.20.128.0/20" },
  { name = "subnet-hub-us-east5-tpu",     region = "us-east5",        ip_cidr_range = "172.10.10.0/29" },
  { name = "subnet-hub-us-east5-tpu2",    region = "us-east5",        ip_cidr_range = "172.10.15.0/29" },
  { name = "subnet-hub-us-east5-voc1",    region = "us-east5",        ip_cidr_range = "172.10.9.0/24" },
  { name = "subnet-hub-us-south1",        region = "us-south1",       ip_cidr_range = "172.20.80.0/20" },

  # --- EUROPE ---
  { name = "subnet-hub-europe-west1",       region = "europe-west1",      ip_cidr_range = "172.20.144.0/20" },
  { name = "subnet-hub-europe-west2",       region = "europe-west2",      ip_cidr_range = "172.20.160.0/20" },
  { name = "subnet-hub-europe-west2-ipv6",  region = "europe-west2",      ip_cidr_range = "192.20.160.0/20" },
  { name = "subnet-hub-europe-west3",       region = "europe-west3",      ip_cidr_range = "172.20.176.0/20" },
  { name = "subnet-hub-europe-west4",       region = "europe-west4",      ip_cidr_range = "172.20.192.0/20" },
  { name = "subnet-hub-europe-west4-tpu",   region = "europe-west4",      ip_cidr_range = "172.10.12.0/29" },
  { name = "subnet-hub-europe-west4-voc1",  region = "europe-west4",      ip_cidr_range = "172.10.11.0/24" },
  { name = "subnet-hub-europe-north1",      region = "europe-north1",     ip_cidr_range = "172.20.208.0/20" },
  { name = "subnet-hub-europe-north2",      region = "europe-north2",     ip_cidr_range = "172.20.224.0/20" },
  { name = "subnet-hub-europe-central2",    region = "europe-central2",   ip_cidr_range = "172.20.240.0/20" },
  { name = "subnet-hub-europe-southwest1",  region = "europe-southwest1", ip_cidr_range = "172.21.0.0/20" },

  # --- ASIA ---
  { name = "subnet-hub-asia-northeast1",      region = "asia-northeast1",  ip_cidr_range = "172.21.96.0/20" },
  { name = "subnet-hub-asia-northeast1-tpu",  region = "asia-northeast1",  ip_cidr_range = "172.10.14.0/29" },
  { name = "subnet-hub-asia-northeast1-tpu2", region = "asia-northeast1",  ip_cidr_range = "172.10.18.0/29" },
  { name = "subnet-hub-asia-northeast1-tpu3", region = "asia-northeast1",  ip_cidr_range = "172.10.16.0/29" },
  { name = "subnet-hub-asia-northeast1-tpu4", region = "asia-northeast1",  ip_cidr_range = "172.10.17.0/29" },
  { name = "subnet-hub-asia-northeast1-voc1", region = "asia-northeast1",  ip_cidr_range = "172.10.13.0/24" },
  { name = "subnet-hub-asia-south1",          region = "asia-south1",      ip_cidr_range = "172.21.64.0/20" },
  { name = "subnet-hub-asia-south2",          region = "asia-south2",      ip_cidr_range = "172.21.80.0/20" },
  { name = "subnet-hub-asia-east2",           region = "asia-east2",       ip_cidr_range = "172.21.112.0/20" },

  # --- MIDDLE EAST ---
  { name = "subnet-hub-me-west1",         region = "me-west1",        ip_cidr_range = "172.21.48.0/20" },
  { name = "subnet-hub-me-central1",      region = "me-central1",     ip_cidr_range = "172.21.16.0/20" },
  { name = "subnet-hub-me-central2",      region = "me-central2",     ip_cidr_range = "172.21.32.0/20" }
]

### Regions with NAT GW
nat_enabled_regions = [
  "us-west1",
  "us-west2",
  "us-west3",
  "us-central1",
  "us-east1",
  "us-east5",
  "europe-west1",
  "europe-west4",
  "europe-north1",
  #"me-centra1",
  #"asia-east1",
  "asia-northeast1",
  "asia-south1"
  ]



# Sequential IPv6 Ranges
/* 
ipv6_cidr_ranges = [
  "2600:1900::/118",
  "2600:1900::400/118",
  "2600:1900::800/118",
  "2600:1900::c00/118",
  "2600:1900::17200/118",
  "2600:1900::1400/118"
]
*/
# Custom VPC Infrastructure with NAT Gateways and Cloud Routers

This Terraform module provisions a custom Virtual Private Cloud (VPC) in Google Cloud Platform (GCP) with the following components:

- Custom VPC with manual subnet creation
- Subnets (with support for secondary IP ranges and IPv6)
- Private Service Access for services like Cloud SQL and Memorystore
- Cloud Routers and Cloud NAT for internet access from private subnets
- Service Networking API enablement and peering

---

### Subnet Configuration

Dynamically creates subnets from var.subnets.
Supports:

- private_ip_google_access = true
- Optional secondary IP ranges
- Optional dual-stack (IPv4/IPv6) based on name matching

---

**Author:** Karl Vietmeier  
**Purpose:** Configure custom VPC infrastructure with support for NAT Gateways, Cloud Routers, and Service Networking.

---

## 🚀 Usage

Run the following Terraform commands with your custom variable file:

```bash
terraform plan -var-file=".\fw.terraform.tfvars"
terraform apply --auto-approve -var-file=".\fw.terraform.tfvars"
terraform destroy --auto-approve -var-file=".\fw.terraform.tfvars"
###===================================================================================###
#
#  File:  vpc.main.tf
#  Created By: Karl Vietmeier
#
#  Purpose:   Configure custom VPC with subnets, NAT GW, and Cloud Routers
# 
###===================================================================================###

/* 
  
Usage:
terraform plan -var-file=".\fw.terraform.tfvars"
terraform apply --auto-approve -var-file=".\fw.terraform.tfvars"
terraform destroy --auto-approve -var-file=".\fw.terraform.tfvars"

*/


###===================================================================================###
#                          Start creating infrastructure resources
###===================================================================================###


locals {
  unique_regions = distinct([for subnet in var.subnets : subnet.region])
}


###===================================================================================###
#                           Private Service Access Peering Setup
###===================================================================================###

# --- VPC Configuration ---
# Need the beta provider to enable IPv6 ULA
resource "google_compute_network" "custom_vpc" {
  provider                 = google-beta
  name                     = var.vpc_name
  auto_create_subnetworks  = false
  enable_ula_internal_ipv6 = true  # REQUIRED to use INTERNAL IPv6 in subnets
}

# Reserve IP range for Private Service Access (used by Cloud SQL, Memorystore, etc.)
resource "google_compute_global_address" "private_service_range" {
  name          = "private-service-access"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.custom_vpc.self_link
  address       = null  # Auto-assigned by GCP
}

# Enable the Service Networking API
resource "google_project_service" "servicenetworking" {
  project = var.project_id
  service = "servicenetworking.googleapis.com"
}


/*
# Doesn't work yet 
resource "google_compute_network_ipv6_ula_allocation" "custom_vpc_ula" {
  network = google_compute_network.custom_vpc.name
}
*/

# --- Subnets with Private Google Access ---
resource "google_compute_subnetwork" "subnets" {
  for_each = { for subnet in var.subnets : subnet.name => subnet }

  name                     = each.value.name
  region                   = each.value.region
  ip_cidr_range            = each.value.ip_cidr_range
  network                  = google_compute_network.custom_vpc.id
  private_ip_google_access = true
  
  # Enable internal IPv6 if name ends in "ipv6"
  stack_type        = can(regex("ipv6$", each.value.name)) ? "IPV4_IPV6" : "IPV4_ONLY"
  ipv6_access_type  = can(regex("ipv6$", each.value.name)) ? "INTERNAL" : null
  
  # If there are secondary IP ranges configured for the subnet, create them.
  dynamic "secondary_ip_range" {
    for_each = try(
      [for r in each.value.secondary_ip_ranges : r if r != null],
      []
    )
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }

}

# --- Routers per Region (only if NAT is enabled) ---
resource "google_compute_router" "routers" {
  for_each = { for region in local.unique_regions : region => region if contains(var.nat_enabled_regions, region) }
  name     = "router-${each.key}"
  network  = google_compute_network.custom_vpc.id
  region   = each.key
}

# --- NAT Gateways per Region ---
resource "google_compute_router_nat" "nats" {
  for_each                           = google_compute_router.routers
  name                               = "nat-${each.key}"
  router                             = each.value.name
  region                             = each.key
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  # Avoid potential race condition  
  depends_on = [
      google_compute_router.routers
  ]

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Create the VPC peering with service networking
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.custom_vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_service_range.name]

  depends_on = [
    google_project_service.servicenetworking
  ]
}


###===================================================================================###
#                                    Outputs
###===================================================================================###
output "nat_enabled_regions" {
  description = "List of regions where Cloud NAT is enabled"
  value       = var.nat_enabled_regions
}

output "subnet_cidrs" {
  description = "List of CIDR blocks for the subnets"
  value       = [for subnet in var.subnets : subnet.ip_cidr_range]
}

output "service_networking_connection" {
  description = "Peering connection to servicenetworking.googleapis.com"
  value       = google_service_networking_connection.private_vpc_connection.network
}
###===================================================================================###
#
#  File:  vpc.main.tf
#  Created By: Karl Vietmeier
#
#  Purpose:   Configure custom VPC with subnets, NAT GW, and Cloud Routers
# 
###===================================================================================###

/* 
  
Usage:
terraform plan -var-file=".\fw.terraform.tfvars"
terraform apply --auto-approve -var-file=".\fw.terraform.tfvars"
terraform destroy --auto-approve -var-file=".\fw.terraform.tfvars"

*/

###===================================================================================###
#                                  Provider Configuration
###===================================================================================###
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.9.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 5.9.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}


###===================================================================================###
#                               Start creating infrastructure resources
###===================================================================================###




locals {
  unique_regions = distinct([for subnet in var.subnets : subnet.region])
}

# --- VPC Configuration ---
resource "google_compute_network" "custom_vpc" {
  provider                 = google-beta
  name                     = var.vpc_name
  auto_create_subnetworks  = false
  enable_ula_internal_ipv6 = true  # REQUIRED to use INTERNAL IPv6 in subnets
}

/* 
resource "google_compute_network_ipv6_ula_allocation" "custom_vpc_ula" {
  network = google_compute_network.custom_vpc.name
}
*/

# --- Subnets with Private Google Access ---
resource "google_compute_subnetwork" "subnets" {
  for_each = { for subnet in var.subnets : subnet.name => subnet }

  name                     = each.value.name
  region                   = each.value.region
  ip_cidr_range            = each.value.ip_cidr_range
  network                  = google_compute_network.custom_vpc.id
  private_ip_google_access = true
  
  # Enable internal IPv6 if name ends in "ipv6"
  stack_type        = can(regex("ipv6$", each.value.name)) ? "IPV4_IPV6" : "IPV4_ONLY"
  ipv6_access_type  = can(regex("ipv6$", each.value.name)) ? "INTERNAL" : null

}

# --- Routers per Region (only if NAT is enabled) ---
resource "google_compute_router" "routers" {
  for_each = { for region in local.unique_regions : region => region if contains(var.nat_enabled_regions, region) }
  name     = "router-${each.key}"
  network  = google_compute_network.custom_vpc.id
  region   = each.key
}

# --- NAT Gateways per Region ---
resource "google_compute_router_nat" "nats" {
  for_each                           = google_compute_router.routers
  name                               = "nat-${each.key}"
  router                             = each.value.name
  region                             = each.key
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  # Avoid potential race condition  
  depends_on = [
      google_compute_router.routers
  ]

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# --- Firewall Rule to Allow Internal Traffic ---
resource "google_compute_firewall" "allow_internal" {
  name    = "allow-all-ports"
  network = google_compute_network.custom_vpc.id

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  direction     = "INGRESS"
  source_ranges = var.ingress_filter
  priority      = 1000
}

###===================================================================================###
#                                    Outputs
###===================================================================================###
output "nat_enabled_regions" {
  description = "List of regions where Cloud NAT is enabled"
  value       = var.nat_enabled_regions
}

output "subnet_cidrs" {
  description = "List of CIDR blocks for the subnets"
  value       = [for subnet in var.subnets : subnet.ip_cidr_range]
}
###===================================================================================###
#                             Provider Configuration
###===================================================================================###

#  File:  provider.tf
#  Created By: Karl Vietmeier
#  Purpose: Configure the GCP Provider TerraForm
#  Google defaults set as Env: vars
#  Using remote state in GCS bucket with prefix for organization and project

terraform {
  backend "gcs" {
    bucket  = "clouddev-itdesk124-tfstate"
    prefix  = "terraform/state/spoke1-pc"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.9.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 5.9.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}
##========================================================================================###
##
##  Values for VPC Spoke1
##
##========================================================================================###

## Project Info
project_id      = "clouddev-itdesk124"
region          = "us-west3"
zone            = "us-west3-a"

default_region = "us-west3"
vpc_name       = "karlv-spoke1"

### Add subnets to the list and re-run apply
### Sticking to simple cidrs to enable easy addition of subnets and secondary IP ranges for services and clusters
# 10.35.0.0/24 - clients/services
# 10.36.0.0/24 - VAST clusters
# 10.37.0.0/24 - VAST clusters


# Define them
subnets = [
  { name = "subnet-spoke1-us-west1",           region = "us-west1",          ip_cidr_range = "10.35.1.0/24" },
  { name = "subnet-spoke1-us-west1-voc",       region = "us-west1",          ip_cidr_range = "10.36.1.0/24" },
  { name = "subnet-spoke1-us-west2",           region = "us-west2",          ip_cidr_range = "10.35.2.0/24" },
  { name = "subnet-spoke1-us-west2-voc",       region = "us-west2",          ip_cidr_range = "10.36.2.0/24" },
  { name = "subnet-spoke1-us-west3",           region = "us-west3",          ip_cidr_range = "10.35.3.0/24" },
  { name = "subnet-spoke1-us-west3-voc",       region = "us-west3",          ip_cidr_range = "10.36.3.0/24" },
  { name = "subnet-spoke1-us-west4",           region = "us-west4",          ip_cidr_range = "10.35.4.0/24" },
  { name = "subnet-spoke1-us-west4-voc",       region = "us-west4",          ip_cidr_range = "10.36.4.0/24" },
  { name = "subnet-spoke1-us-central1",        region = "us-central1",       ip_cidr_range = "10.35.5.0/24" },
  { name = "subnet-spoke1-us-central1-voc",    region = "us-central1",       ip_cidr_range = "10.36.5.0/24" },
  { name = "subnet-spoke1-us-south1",          region = "us-south1",         ip_cidr_range = "10.35.6.0/24" },
  { name = "subnet-spoke1-us-east1",           region = "us-east1",          ip_cidr_range = "10.35.7.0/24" },
  { name = "subnet-spoke1-us-east4",           region = "us-east4",          ip_cidr_range = "10.35.8.0/24" },
  { name = "subnet-spoke1-us-east5",           region = "us-east5",          ip_cidr_range = "10.35.9.0/24" },
  { name = "subnet-spoke1-europe-west1",       region = "europe-west1",      ip_cidr_range = "10.35.10.0/24" },
  { name = "subnet-spoke1-europe-west2",       region = "europe-west2",      ip_cidr_range = "10.35.11.0/24" },
  { name = "subnet-spoke1-europe-west3",       region = "europe-west3",      ip_cidr_range = "10.35.12.0/24" },
  { name = "subnet-spoke1-europe-west4",       region = "europe-west4",      ip_cidr_range = "10.35.13.0/24" },
  { name = "subnet-spoke1-europe-north1",      region = "europe-north1",     ip_cidr_range = "10.35.14.0/24" },
  { name = "subnet-spoke1-europe-north2",      region = "europe-north2",     ip_cidr_range = "10.35.15.0/24" },
  { name = "subnet-spoke1-europe-central2",    region = "europe-central2",   ip_cidr_range = "10.35.16.0/24" },
  { name = "subnet-spoke1-europe-southwest1",  region = "europe-southwest1", ip_cidr_range = "10.35.17.0/24" },
  { name = "subnet-spoke1-me-central1",        region = "me-central1",       ip_cidr_range = "10.35.18.0/24" },
  { name = "subnet-spoke1-me-central2",        region = "me-central2",       ip_cidr_range = "10.35.19.0/24" },
  { name = "subnet-spoke1-me-west1",           region = "me-west1",          ip_cidr_range = "10.35.20.0/24" },
  { name = "subnet-spoke1-asia-south1",        region = "asia-south1",       ip_cidr_range = "10.35.21.0/24" },
  { name = "subnet-spoke1-asia-south2",        region = "asia-south2",       ip_cidr_range = "10.35.22.0/24" },
  { name = "subnet-spoke1-asia-east1",         region = "asia-east1",        ip_cidr_range = "10.35.23.0/24" },
  { name = "subnet-spoke1-asia-east2",         region = "asia-east2",        ip_cidr_range = "10.35.24.0/24" }
]

### Regions with NAT GW
nat_enabled_regions = [
  "us-west2",
  "us-west3",
  "us-east1",
  "us-central1",
  "us-east5",
  "europe-west1",
  "europe-north1",
  "me-centra1",
  "asia-east1",
  "asia-south1"
  ]

# Sequential Rnges
/* 
ipv6_cidr_ranges = [
  "2600:1900::/118",
  "2600:1900::400/118",
  "2600:1900::800/118",
  "2600:1900::c00/118",
  "2600:1900::17200/118",
  "2600:1900::1400/118"
] 
*/
# ========================
# This configuration has been sanitized to remove sensitive information.
# Replace placeholders (e.g., <your-project-id>, <your-region>) with actual values.
# ========================

# Project Info
project_id      = "<your-project-id>"
region          = "<your-region>"
zone            = "<your-zone>"

default_region = "<your-default-region>"
vpc_name       = "<your-vpc-name>"

### Subnets (Adjust as needed for your specific use case)
subnets = [
  { name = "subnet-hub-west1"          , region = "us-west1"        , ip_cidr_range = "111.20.0.0/20" },
  { name = "subnet-hub-west2"          , region = "us-west2"        , ip_cidr_range = "111.21.0.0/20" },
  { name = "subnet-hub-west3"          , region = "us-west3"        , ip_cidr_range = "111.22.0.0/20" },
  { name = "subnet-hub-west4"          , region = "us-west4"        , ip_cidr_range = "111.23.0.0/20" },
  { name = "subnet-hub-central1"       , region = "us-central1"     , ip_cidr_range = "111.24.0.0/20" },
  { name = "subnet-hub-south1"         , region = "us-south1"       , ip_cidr_range = "111.25.0.0/20" },
  { name = "subnet-hub-east1"          , region = "us-east1"        , ip_cidr_range = "111.26.0.0/20" },
  { name = "subnet-hub-east4"          , region = "us-east4"        , ip_cidr_range = "111.27.0.0/20" },
  { name = "subnet-hub-east5"          , region = "us-east5"        , ip_cidr_range = "111.28.0.0/20" },
  { name = "subnet-hub-europe-west1"   , region = "europe-west1"    , ip_cidr_range = "111.29.0.0/20" },
  { name = "subnet-hub-europe-west2"   , region = "europe-west2"    , ip_cidr_range = "111.30.0.0/20" },
  { name = "subnet-hub-europe-west3"   , region = "europe-west3"    , ip_cidr_range = "111.31.0.0/20" },
  { name = "subnet-hub-europe-west4"   , region = "europe-west4"    , ip_cidr_range = "111.32.0.0/20" },
  { name = "subnet-hub-europe-north1"  , region = "europe-north1"   , ip_cidr_range = "111.33.0.0/20" },
  { name = "subnet-hub-europe-north2"  , region = "europe-north2"   , ip_cidr_range = "111.34.0.0/20" },
  { name = "subnet-hub-europe-central2", region = "europe-central2" , ip_cidr_range = "111.35.0.0/20" },
  { name = "subnet-hub-europe-southwest1", region = "europe-southwest1", ip_cidr_range = "111.36.0.0/20" },
  { name = "subnet-hub-me-central1"    , region = "me-central1"     , ip_cidr_range = "111.37.0.0/20" },
  { name = "subnet-hub-me-central2"    , region = "me-central2"     , ip_cidr_range = "111.38.0.0/20" },
  { name = "subnet-hub-me-west1"       , region = "me-west1"        , ip_cidr_range = "111.39.0.0/20" },
  { name = "subnet-hub-asia-south1"    , region = "asia-south1"     , ip_cidr_range = "111.40.0.0/20" },
  { name = "subnet-hub-asia-south2"    , region = "asia-south2"     , ip_cidr_range = "111.41.0.0/20" },
  { name = "subnet-hub-asia-east1"     , region = "asia-east1"      , ip_cidr_range = "111.42.0.0/20" },
  { name = "subnet-hub-asia-east2"     , region = "asia-east2"      , ip_cidr_range = "111.43.0.0/20" }
]

### Regions with NAT Gateway
nat_enabled_regions = [
  "us-west1",
  "us-west2",
  "us-west3",
  "us-west4",
  "us-east1",
  "us-east5",
  "europe-west1",
  "europe-north1",
  "me-central1",
  "asia-east1",
  "asia-south1"
]

ingress_filter = [
  "47.144.111.57",     # My ISP Address
  "35.191.0.0/16",     # GCP health checks
  "130.211.0.0/22",    # GCP health checks
  "192.168.0.0/16",    # Docker
  "172.16.0.0/12",     # Docker
  "10.0.0.0/8"         # Internal
]
# Define Variables
###--- Provider Info
variable "region" {
  description = "Region to deploy resources"
}

variable "zone" {
  description = "Availbility Zone"
}

variable "project_id" {
  description = "GCP Project ID"
}

variable "default_region" {
  description = "Default region"
  type        = string
  default     = "us-west2"
}

variable "vpc_name" {
  description = "Name of the custom VPC"
  type        = string
  default     = "custom-vpc"
}

variable "subnets" {
  description = "List of subnets with name, region, CIDR, and secondary cidr ranges"
  type = list(object({
    name                = string
    region              = string
    ip_cidr_range       = string
    ipv6_cidr_range     = optional(string)
    secondary_ip_ranges = optional(list(object({
      range_name    = string
      ip_cidr_range = string
    })))
  }))
}

variable "nat_enabled_regions" {
  description = "List of regions to deploy Cloud NAT"
  type        = list(string)
  default     = []
}