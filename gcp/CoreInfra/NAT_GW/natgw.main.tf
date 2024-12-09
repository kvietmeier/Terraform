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

/* 
  
Usage:
terraform plan -var-file=".\multivm_map.tfvars"
terraform apply --auto-approve -var-file=".\multivm_map.tfvars"
terraform destroy --auto-approve -var-file=".\multivm_map.tfvars"

*/

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
