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
