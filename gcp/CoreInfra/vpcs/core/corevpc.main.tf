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
