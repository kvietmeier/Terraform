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
      version = "4.51.0"
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
  name                    = var.vpc_name
  auto_create_subnetworks = false
}

# --- Subnets with Private Google Access ---
resource "google_compute_subnetwork" "subnets" {
  for_each = { for subnet in var.subnets : subnet.name => subnet }

  name                     = each.value.name
  region                   = each.value.region
  ip_cidr_range            = each.value.ip_cidr_range
  network                  = google_compute_network.custom_vpc.id
  private_ip_google_access = true
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

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# --- Firewall Rule to Allow Internal Traffic ---
resource "google_compute_firewall" "allow_internal" {
  name    = "allow-all-ports"
  network = google_compute_network.custom_vpc.name

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
