###===================================================================================###
#
#  Created By: Karl Vietmeier
#
#  Purpose: Create a rule that opens all ports but maintains ingress filters
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

###-----   For testing - Open all of the ports
resource "google_compute_firewall" "allow_all_ports" {
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

  direction     = var.rule_direction
  source_ranges = var.ingress_filter    # Ingress filter
  priority      = var.rule_priority     # Set low priority so it has precidence
  
  #target_tags = ["standard-services", "health-checks"]   # Tag for instances needing this firewall rule
}


