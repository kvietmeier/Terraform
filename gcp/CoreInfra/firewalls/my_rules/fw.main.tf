###===================================================================================###
#
#  File:  fw.main.tf
#  Created By: Karl Vietmeier
#
#  Purpose:   Configure custom firewall rules in the default VPC
# 
#  Files in Module:
#    fw.main.tf
#    fw.variables.tf
#    fw.terraform.tfvars
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

###--- Create the FW Rule/s for standard services
resource "google_compute_firewall" "default_services_rules" {
  
  name        = var.myrules_name
  network     = var.vpc_name              
  description = var.description
  priority    = var.svcs_priority
  direction   = var.ingress_rule

  allow {
    protocol = "tcp"
    ports    = var.tcp_ports
  }
  
  allow {
    protocol = "udp"
    ports    = var.udp_ports
  }

  allow {
    protocol = "icmp"                    # ICMP for ping/diagnostic
  }

  source_ranges = var.ingress_filter     # CIDR - Ingress filter
  
  #target_tags = ["standard-services"]   # Tag for instances needing this firewall rule

}

###--- Create the FW Rule/s for Applications
resource "google_compute_firewall" "custom_app_rules" {
  
  name        = var.apprules_name
  network     = var.vpc_name              
  description = var.description
  direction   = var.ingress_rule
  priority    = var.app_priority

  
  allow {
    protocol = "tcp"
    ports    = var.app_tcp
  }

  allow {
    protocol = "icmp"                    # ICMP for ping/diagnostic
  }

  source_ranges = var.ingress_filter     # CIDR - Ingress filter
  
  #target_tags = ["standard-services"]   # Tag for instances needing this firewall rule

}

###--- Create the FW Rule/s for Active Directory
resource "google_compute_firewall" "addc_rules" {
  
  ###--- Rules for Active Directory
  name        = var.addc_name
  network     = var.vpc_name              
  description = var.description
  direction   = var.ingress_rule
  priority    = var.addc_priority

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = var.addc_tcp_ports
  }

  allow {
    protocol = "udp"
    ports    = var.addc_udp_ports
  }

  source_ranges = var.ingress_filter     # CIDR - Ingress filter
  
  # Limit scope
  #source_tags   = ["ad-domaincontroller"]
  #target_tags   = ["ad-domaincontroller"]
}

/*
# WIP - egress rule 
resource "google_compute_firewall" "egress_rules" {
  ###--- Rules for egress
  name        = var.egress_rule
  network     = var.vpc_name              
  description = var.egress_desc
  direction   = var.egress_rule
  priority    = var.egress_priority

  source_ranges = var.egress_filter     # CIDR - Ingress filter

  allow {
    protocol = var.egress_ports
  }
}
*/