###===================================================================================###
#
#  File:  fw_openall.main.tf
#  Created By: Karl Vietmeier
#
#  Purpose:  Create default GCP Firewall rules
#
#  This is a really bad idea!!!
# 
#  Files in Module:
#    main.tf
#    variables.tf
#    variables.tfvars
#
###===================================================================================###

/* 
  
Usage:
terraform plan -var-file=".\fw_defaults.tfvars"
terraform apply --auto-approve -var-file=".\fw_defaults.tfvars"
terraform destroy --auto-approve -var-file=".\fw_defaults.tfvars"

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

resource "google_compute_firewall" "allow_all" {
  name    = "allow-all-traffic"
  network = "default" # Replace with your network name if different

  direction = "INGRESS"
  priority  = 10

  source_ranges = ["0.0.0.0/0"] # Allow traffic from all IPs (external and internal)

  allow {
    protocol = "all" # Allow all protocols
  }
}
