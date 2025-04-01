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

###--- Provider
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
#     Start creating infrastructure resources
###===================================================================================###

### Create a Custom VPC
resource "google_compute_network" "custom_vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false  # Custom mode VPC (no automatic subnets)
}

# Create Subnets Dynamically from List Variable
resource "google_compute_subnetwork" "subnets" {
  for_each                = { for subnet in var.subnets : subnet.name => subnet }
  name                    = each.value.name
  network                 = google_compute_network.custom_vpc.id
  ip_cidr_range           = each.value.ip_cidr_range
  region                  = each.value.region
  private_ip_google_access = true  # Enable Private Google Access
}

# Create Cloud Routers & NAT for each subnet's region
resource "google_compute_router" "routers" {
  for_each = { for subnet in var.subnets : subnet.region => subnet }
  name     = "router-${each.value.region}"
  network  = google_compute_network.custom_vpc.id
  region   = each.value.region
}

resource "google_compute_router_nat" "nats" {
  for_each                           = google_compute_router.routers
  name                               = "nat-${each.key}"
  router                             = each.value.name
  region                             = each.key
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# Firewall Rule to Allow Internal Traffic
resource "google_compute_firewall" "allow-internal" {
  name    = "allow-all-ports"
  network = var.vpc_name                     # Change if using a different network

  allow {
    protocol = "tcp"
    ports =  ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports =  ["0-65535"]
  }

  allow {
    protocol = "icmp"                   # ICMP for ping/diagnostic
  }

  direction     = ingress
  source_ranges = var.ingress_filter    # Ingress filter
  priority      = 1000     # Set low priority so it has precidence
  
  #target_tags = ["standard-services", "health-checks"]   # Tag for instances needing this firewall rule
}
