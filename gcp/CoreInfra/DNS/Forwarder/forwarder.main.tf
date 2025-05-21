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
      ipv4_address = var.vastcluser_dns
    }
  }
}


###===================================================================================###
#                                   Outputs
###===================================================================================###
