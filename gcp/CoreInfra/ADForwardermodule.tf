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

}