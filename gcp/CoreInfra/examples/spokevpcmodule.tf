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