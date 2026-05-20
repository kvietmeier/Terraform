#### License

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

}