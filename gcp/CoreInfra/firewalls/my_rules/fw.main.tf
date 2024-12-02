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

###--- Create the FW Rule/s
resource "google_compute_firewall" "default_services_rules" {
  name        = var.stdservices_rules_name
  network     = var.vpc_name              
  description = var.description

  # Define the direction of traffic
  direction = "INGRESS"
  priority    = var.rule_priority_services

  allow {
    protocol = "tcp"
    ports    = var.tcp_ports
  }
  
  allow {
    protocol = "tcp"
    ports    = var.app_tcp
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

/*
resource "google_compute_firewall" "application_rules" {
  name        = var.app_rules_name
  network     = var.vpc_name        
  description = var.app_description

  # Define the direction of traffic
  direction = "INGRESS"
  priority  = var.app_priority

  allow {
    protocol = "tcp"
    ports    = var.app_tcp
  }

  source_ranges = var.ingress_filter    # Ingress filter

  #target_tags = ["standard-services"]   # Tag for instances needing this firewall rule
}
*/

/*
###-----   For testing - Open all of the ports
resource "google_compute_firewall" "allow_all_ports" {
  name    = "allow-all-ports"
  network = "default"                     # Change if using a different network

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

  direction     = "INGRESS"
  source_ranges = var.ingress_filter    # Ingress filter
  priority      = 100
  
  #target_tags = ["standard-services", "voc-health-check"]   # Tag for instances needing this firewall rule
}
*/


