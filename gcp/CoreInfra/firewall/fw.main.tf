###===================================================================================###
#
#  File:  vpc.main.tf
#  Created By: Karl Vietmeier
#
#  Terraform Module Code
#  Purpose:   Configure Firewall rules in the default VPC
# 
#  Files in Module:
#    fw.main.tf
#    fw.variables.tf
#    fw.terraform.tfvars
#
###===================================================================================###

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


###-----   For testing - allow everything
resource "google_compute_firewall" "allow_ingress_everything" {
  name    = "allow-ingress-everything"
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
  source_ranges = var.allowed_ranges    # Ingress filter
  #source_ranges = ["0.0.0.0/0"]
  priority      = 100
}





/*
resource "google_compute_firewall" "default_vpc_firewall" {
  name        = var.fw_rule_name
  network     = var.vpc_name            # Set to Default VPC network
  description = var.description

  # Define the direction of traffic
  direction = "INGRESS"
  priority  = var.rule_priority

  allow {
    protocol = "tcp"
    ports    = var.tcp_ports
  }
  
  allow {
    protocol = "tcp"
    ports    = var.app_ports
  }

  allow {
    protocol = "udp"
    ports    = var.udp_ports
  }

  allow {
    protocol = "icmp"                   # ICMP for ping/diagnostic
  }

  source_ranges = var.allowed_ranges    # Ingress filter

  #target_tags = ["standard-services"]   # Tag for instances needing this firewall rule
}
*/

/*  Breaking up rules
###--- Create the FW Rule/s
resource "google_compute_firewall" "defaultvpc_stdservices_rules" {
  name        = var.stdservices_rules_name
  network     = var.vpc_name            # Set to Default VPC network
  description = var.description

  # Define the direction of traffic
  direction = "INGRESS"
  priority    = var.rule_priority_services

  allow {
    protocol = "tcp"
    ports    = var.tcp_ports_stdservices
  }
  
  allow {
    protocol = "udp"
    ports    = var.udp_ports_stdservices
  }

  allow {
    protocol = "icmp"                   # ICMP for ping/diagnostic
  }

  source_ranges = var.allowed_services    # Ingress filter

}

resource "google_compute_firewall" "defaultvpc_app_rules" {
  name        = var.app_rules_name
  network     = var.vpc_name            # Set to Default VPC network
  description = var.description

  # Define the direction of traffic
  direction = "INGRESS"
  priority  = var.rule_priority_app

  allow {
    protocol = "tcp"
    ports    = var.tcp_app_ports
  }

  source_ranges = var.allowed_app    # Ingress filter

  #target_tags = ["standard-services"]   # Tag for instances needing this firewall rule
}
*/




