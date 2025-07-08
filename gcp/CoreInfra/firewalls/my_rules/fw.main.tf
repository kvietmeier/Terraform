###===================================================================================###
#  File:        fw.main.tf
#  Author:      Karl Vietmeier
#
#  Purpose:     Define and apply custom firewall rules for the 'karlv-corevpc' VPC 
#               on Google Cloud Platform (GCP). Rules are scoped using target tags 
#               to enforce role-based access for standard services, Active Directory,
#               VAST infrastructure, and security controls (e.g., ICMP restrictions).
#
#  Usage:
#    terraform plan -var-file="fw.terraform.tfvars"
#    terraform apply --auto-approve -var-file="fw.terraform.tfvars"
#    terraform destroy --auto-approve -var-file="fw.terraform.tfvars"
#
#  Structure:
#    - Standard service rules (TCP, UDP, ICMP for SSH, DNS, HTTP, etc.)
#    - Application-specific rules (e.g., VAST on Cloud)
#    - Active Directory support (LDAP, Kerberos, DNS, etc.)
#    - ICMP control: allow trusted sources, deny public pings
#
#  Related Files:
#    - fw.variables.tf       → Variable declarations
#    - fw.terraform.tfvars   → Environment-specific values (excluded from repo)
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
  
  # Optional: restrict to specific target tags
  #target_tags = ["standard-services"]   # Tag for instances needing this firewall rule

}

###--- Create the FW Rule/s for Applications
resource "google_compute_firewall" "custom_app_rules" {
  
  name        = var.vast_rules_name
  network     = var.vpc_name              
  description = var.description
  direction   = var.ingress_rule
  priority    = var.vast_priority

  
  allow {
    protocol = "tcp"
    ports    = var.vast_tcp
  }

  allow {
    protocol = "icmp"                    # ICMP for ping/diagnostic
  }

  source_ranges = var.ingress_filter     # CIDR - Ingress filter
  
  # Optional: restrict to specific target tags
  #target_tags = ["standard-services"]   

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
  
  # Optional: restrict to specific target tags
  #source_tags   = ["ad-domaincontroller"]
  #target_tags   = ["ad-domaincontroller"]
}
