## Custom VPC Infrastructure with NAT Gateways and Cloud Routers

This Terraform module provisions a custom Virtual Private Cloud (VPC) in Google Cloud Platform (GCP) with the following components:

- A named custom VPC with manual subnet creation
- Subnets across multiple GCP regions
- Optional secondary IP ranges (e.g., for services like GKE or VAST)
- IPv6 dual-stack support (where enabled)
- Private Google access on all subnets
- Cloud Routers and Cloud NAT (in user-specified regions)
- VPC Peering for Private Service Access (used by Cloud SQL, Memorystore, etc.)

---

### Subnet Configuration

Dynamically creates subnets from var.subnets.
Supports:

- region: GCP region
- name: Subnet name
- private_ip_google_access: true/false
- ip_cidr_range: Primary IPv4 CIDR block
- ipv6_cidr_range (optional): IPv6 block (for dual-stack subnets)
- secondary_ip_ranges (optional): Additional named secondary CIDR blocks (e.g., for services)

### Requirements

- Terraform ≥ 1.4
- Google Cloud Provider ≥ 5.9
- **Google Beta Provider for ipv6 EULA**
- Enabled APIs: compute.googleapis.com, servicenetworking.googleapis.com

---

### Terraform Resource References

- [compute_network](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network)
- [compute_subnetwork](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork)
- [compute_router](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router)
- [compute_router_nat](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat)
- [compute_network_ipv6_ula_allocation](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_ipv6_ula_allocation)
- [compute_global_adress](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_adress)
- [service_networking_connection](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_networking_connection)
- [project_service](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service)

---

**Author:** Karl Vietmeier  

---

### Usage

Run the following Terraform commands with your custom variable file:

```bash
terraform plan -var-file=".\corevpc.terraform.tfvars"
terraform apply --auto-approve -var-file=".\corevpc.terraform.tfvars"
terraform destroy --auto-approve -var-file=".\corevpc.terraform.tfvars"
```
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
  routing_mode             = "GLOBAL"   
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



/*

resource "google_compute_global_address" "private_service_range" {
  name          = "private-service-access"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.custom_vpc.self_link
  
  # We use 192.168.0.0/16 for Cloud SQL.
  # It is distinct from 10.x (Voc) and 172.20.x (Hubs).
  address       = "192.168.0.0" 
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.custom_vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_service_range.name]
  depends_on              = [google_project_service.servicenetworking]
}
*/###===================================================================================###
#                                  Provider Configuration
###===================================================================================###
terraform {
  backend "gcs" {
    bucket  = "clouddev-itdesk124-tfstate"
    prefix  = "terraform/state/core-vpc"
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
###========================================================================================###
##  VPC Configuration Overview
##
##  - Configures a custom VPC and defines multiple subnets across regions
##  - Assigns primary and secondary IP ranges to subnets
##  - Enables IPv6 addressing for select subnets
##  - Specifies regions where NAT Gateways are deployed
##
##  NOTE: Only the associated *.tfvars file should be edited to customize this configuration.
###========================================================================================###

## Project Info
project_id      = "clouddev-itdesk124"
region          = "us-west3"
zone            = "us-west3-a"

default_region = "us-west3"
vpc_name       = "karlv-corevpc"
###========================================================================================###
##  Variable Definitions for VPC Infrastructure Deployment
##
##  - Defines input variables for region, zone, project ID, and VPC settings
##  - Includes subnet configuration with optional IPv6 and secondary ranges
##  - Specifies regions where Cloud NAT should be enabled
##
##  These variables are used across modules to provision a custom network topology.
###========================================================================================###

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

# --- VPC Settings ---
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

# --- Subnet Definitions ---
/* 
List of subnet definitions. Each entry includes:
- name: Subnet name
- region: GCP region
- ip_cidr_range: Primary IPv4 CIDR block
- ipv6_cidr_range (optional): IPv6 block (for dual-stack subnets)
- secondary_ip_ranges (optional): Additional named secondary CIDR blocks (e.g., for services)
*/
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

# --- Cloud NAT Configuration ---
variable "nat_enabled_regions" {
  description = "List of regions to deploy Cloud NAT"
  type        = list(string)
  default     = []
}###========================================================================================###
##  VPC Configuration Overview
##
##  - Configures a custom VPC and defines multiple subnets across regions
##  - Assigns primary and secondary IP ranges to subnets
##  - Enables IPv6 addressing for select subnets
##  - Specifies regions where NAT Gateways are deployed
##
##  NOTE: Only the associated *.tfvars file should be edited to customize this configuration.
###========================================================================================###


### Real from gcloud - 
subnets = [
  # --- US CENTRAL ---
  { name = "subnet-hub-us-central1",      region = "us-central1",      ip_cidr_range = "172.20.64.0/20" },
  { name = "subnet-hub-us-central1-voc1", region = "us-central1",      ip_cidr_range = "172.9.1.0/24" },
  { name = "subnet-hub-us-central1-voc2", region = "us-central1",      ip_cidr_range = "172.11.1.0/24" },

  # --- US WEST ---
  { name = "subnet-hub-us-west1-01",      region = "us-west1",        ip_cidr_range = "172.20.0.0/20" },
  { name = "subnet-hub-us-west1-voc1",    region = "us-west1",        ip_cidr_range = "172.10.1.0/24" },
  { name = "subnet-hub-us-west1-voc2",    region = "us-west1",        ip_cidr_range = "172.10.2.0/24" },
  { name = "subnet-hub-us-west1-voc3",    region = "us-west1",        ip_cidr_range = "172.10.3.0/24" },
  { name = "subnet-hub-us-west1-voc4",    region = "us-west1",        ip_cidr_range = "172.10.4.0/24" },
  { name = "subnet-hub-us-west2",         region = "us-west2",        ip_cidr_range = "172.20.16.0/20" },
  { name = "subnet-hub-us-west2-02",      region = "us-west2",        ip_cidr_range = "172.21.128.0/20" },
  { name = "subnet-hub-us-west2-03",      region = "us-west2",        ip_cidr_range = "172.21.144.0/20" },
  { name = "subnet-hub-us-west2-voc1",    region = "us-west2",        ip_cidr_range = "172.5.1.0/24" },
  { name = "subnet-hub-us-west2-voc2",    region = "us-west2",        ip_cidr_range = "172.6.1.0/24" },
  { name = "subnet-hub-us-west2-voc3",    region = "us-west2",        ip_cidr_range = "172.7.1.0/24" },
  { name = "subnet-hub-us-west2-voc4",    region = "us-west2",        ip_cidr_range = "172.8.1.0/24" },
  { name = "subnet-hub-us-west2-ipv6",    region = "us-west2",        ip_cidr_range = "192.20.16.0/20" },
  { name = "subnet-hub-us-west3",         region = "us-west3",        ip_cidr_range = "172.20.32.0/20" },
  { name = "subnet-hub-us-west4",         region = "us-west4",        ip_cidr_range = "172.20.48.0/20" },

  # --- US EAST & SOUTH ---
  { name = "subnet-hub-us-east1",         region = "us-east1",        ip_cidr_range = "172.20.96.0/20" },
  { name = "subnet-hub-us-east1-voc1",    region = "us-east1",        ip_cidr_range = "172.10.5.0/24" },
  { name = "subnet-hub-us-east1-voc2",    region = "us-east1",        ip_cidr_range = "172.10.6.0/24" },
  { name = "subnet-hub-us-east1-voc3",    region = "us-east1",        ip_cidr_range = "172.10.7.0/24" },
  { name = "subnet-hub-us-east1-voc4",    region = "us-east1",        ip_cidr_range = "172.10.8.0/24" },
  { name = "subnet-hub-us-east4",         region = "us-east4",        ip_cidr_range = "172.20.112.0/20" },
  { name = "subnet-hub-us-east5",         region = "us-east5",        ip_cidr_range = "172.20.128.0/20" },
  { name = "subnet-hub-us-east5-tpu",     region = "us-east5",        ip_cidr_range = "172.10.10.0/29" },
  { name = "subnet-hub-us-east5-tpu2",    region = "us-east5",        ip_cidr_range = "172.10.15.0/29" },
  { name = "subnet-hub-us-east5-voc1",    region = "us-east5",        ip_cidr_range = "172.10.9.0/24" },
  { name = "subnet-hub-us-south1",        region = "us-south1",       ip_cidr_range = "172.20.80.0/20" },

  # --- EUROPE ---
  { name = "subnet-hub-europe-west1",       region = "europe-west1",      ip_cidr_range = "172.20.144.0/20" },
  { name = "subnet-hub-europe-west2",       region = "europe-west2",      ip_cidr_range = "172.20.160.0/20" },
  { name = "subnet-hub-europe-west2-ipv6",  region = "europe-west2",      ip_cidr_range = "192.20.160.0/20" },
  { name = "subnet-hub-europe-west3",       region = "europe-west3",      ip_cidr_range = "172.20.176.0/20" },
  { name = "subnet-hub-europe-west4",       region = "europe-west4",      ip_cidr_range = "172.20.192.0/20" },
  { name = "subnet-hub-europe-west4-tpu",   region = "europe-west4",      ip_cidr_range = "172.10.12.0/29" },
  { name = "subnet-hub-europe-west4-voc1",  region = "europe-west4",      ip_cidr_range = "172.10.11.0/24" },
  { name = "subnet-hub-europe-north1",      region = "europe-north1",     ip_cidr_range = "172.20.208.0/20" },
  { name = "subnet-hub-europe-north2",      region = "europe-north2",     ip_cidr_range = "172.20.224.0/20" },
  { name = "subnet-hub-europe-central2",    region = "europe-central2",   ip_cidr_range = "172.20.240.0/20" },
  { name = "subnet-hub-europe-southwest1",  region = "europe-southwest1", ip_cidr_range = "172.21.0.0/20" },

  # --- ASIA ---
  { name = "subnet-hub-asia-northeast1",      region = "asia-northeast1",  ip_cidr_range = "172.21.96.0/20" },
  { name = "subnet-hub-asia-northeast1-tpu",  region = "asia-northeast1",  ip_cidr_range = "172.10.14.0/29" },
  { name = "subnet-hub-asia-northeast1-tpu2", region = "asia-northeast1",  ip_cidr_range = "172.10.18.0/29" },
  { name = "subnet-hub-asia-northeast1-tpu3", region = "asia-northeast1",  ip_cidr_range = "172.10.16.0/29" },
  { name = "subnet-hub-asia-northeast1-tpu4", region = "asia-northeast1",  ip_cidr_range = "172.10.17.0/29" },
  { name = "subnet-hub-asia-northeast1-voc1", region = "asia-northeast1",  ip_cidr_range = "172.10.13.0/24" },
  { name = "subnet-hub-asia-south1",          region = "asia-south1",      ip_cidr_range = "172.21.64.0/20" },
  { name = "subnet-hub-asia-south2",          region = "asia-south2",      ip_cidr_range = "172.21.80.0/20" },
  { name = "subnet-hub-asia-east2",           region = "asia-east2",       ip_cidr_range = "172.21.112.0/20" },

  # --- MIDDLE EAST ---
  { name = "subnet-hub-me-west1",         region = "me-west1",        ip_cidr_range = "172.21.48.0/20" },
  { name = "subnet-hub-me-central1",      region = "me-central1",     ip_cidr_range = "172.21.16.0/20" },
  { name = "subnet-hub-me-central2",      region = "me-central2",     ip_cidr_range = "172.21.32.0/20" }
]

### Regions with NAT GW
nat_enabled_regions = [
  "us-west1",
  "us-west2",
  "us-west3",
  "us-central1",
  "us-east1",
  "us-east5",
  "europe-west1",
  "europe-west4",
  "europe-north1",
  #"me-centra1",
  #"asia-east1",
  "asia-northeast1",
  "asia-south1"
  ]



# Sequential IPv6 Ranges
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
