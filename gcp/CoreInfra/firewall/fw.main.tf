###===================================================================================###
#
#  File:  vpc.main.tf
#  Created By: Karl Vietmeier
#
#  Terraform Module Code
#  Purpose:   Configure Firewall rules in the default VPC
# 
#  Files in Module:
#    vpc.main.tf
#    vpc.variables.tf
#    vpc.terraform.tfvars
#
###===================================================================================###

/* 

Put Usage Documentation here

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
resource "google_compute_firewall" "default_vpc_firewall" {
  name        = var.fw_rule_name
  network     = var.vpc_name            # Set to Default VPC network
  description = var.description

  # Define the direction of traffic
  direction = var.rule_direction
  priority  = var.rule_priority

  allow {
    protocol = "tcp"
    ports    = var.tcp_ports
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