#### License

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
}