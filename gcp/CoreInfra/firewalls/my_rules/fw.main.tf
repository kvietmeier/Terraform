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


resource "google_compute_firewall" "allow_replication_between_addc" {
  ###--- Rules for Active Directory

  name    = "allow-replication-between-addc"
  network = var.vpc_name              

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

  direction     = var.rule_direction
  priority      = var.addc_priority
  source_ranges = var.ingress_filter     # CIDR - Ingress filter
  
  source_tags   = ["ad-domaincontroller"]
  target_tags   = ["ad-domaincontroller"]
}
