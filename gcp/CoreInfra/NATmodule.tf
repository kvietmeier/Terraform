#### License

``` text
SPDX-License-Identifier: Apache-2.0
```
### Create NAT Gateways

You need a NAT Gateway and router in every region you have subnets  
This module creates gateways using the "regions()" list

---

#### Notes

Put Notes Here

---

#### Author/s

* **Karl Vietmeier**

#### License

This project is licensed under the Apache License 

#### Acknowledgments

* None so far other than the many good examples out there.
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
###===================================================================================###
#
#  File:  natgw.tfvars
#  Created By: Karl Vietmeier
#
###===================================================================================###


# Project Info
project_id      = "clouddev-itdesk124"
default_region  = "us-west2"
default_zone    = "us-west2-a"

# VPC Config
vpc_name        = "default"

# Region List
regions = [ "us-west1",
            "us-east1", 
            "us-east4", 
            "us-central1", 
            "europe-west1",
            "asia-east1", 
            "asia-east2" 
]

### Curent regions:
/*
africa-south1      
asia-east1         
asia-east2        
asia-northeast1  
asia-northeast2 
asia-northeast3
asia-south1   
asia-south2  
asia-southeast1
asia-southeast2         
australia-southeast1   
australia-southeast2  
europe-central2      
europe-north1 
europe-southwest1  
europe-west1      
europe-west10    
europe-west12   
europe-west2   
europe-west3  
europe-west4 
europe-west6
europe-west8    
europe-west9   
me-central1   
me-central2  
me-west1    
northamerica-northeast1  
northamerica-northeast2  
northamerica-south1     
southamerica-east1     
southamerica-west1    
us-central1             
us-east1               
us-east4              
us-east5             
us-south1           
us-west1           
us-west2          
us-west3         
us-west4        
*/###===================================================================================###
#
#  File:  natgw.tfvars.txt
#  Created By: Karl Vietmeier
#
###===================================================================================###


# Project Info
project_id      = "project_id"
default_region  = "us-west3"
default_zone    = "us-west3-a"

# VPC Config
vpc_name        = "default"

# Region List
regions = [ "us-west3",
            "asia-east2" 
]

### Regions:
africa-south1      
asia-east1         
asia-east2        
asia-northeast1  
asia-northeast2 
asia-northeast3
asia-south1   
asia-south2  
asia-southeast1
asia-southeast2         
australia-southeast1   
australia-southeast2  
europe-central2      
europe-north1 
europe-southwest1  
europe-west1      
europe-west10    
europe-west12   
europe-west2   
europe-west3  
europe-west4 
europe-west6
europe-west8    
europe-west9   
me-central1   
me-central2  
me-west1    
northamerica-northeast1  
northamerica-northeast2  
northamerica-south1     
southamerica-east1     
southamerica-west1    
us-central1             
us-east1               
us-east4              
us-east5             
us-south1           
us-west1           
us-west2          
us-west3         
us-west4        