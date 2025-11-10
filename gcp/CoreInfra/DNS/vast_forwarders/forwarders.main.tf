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
}