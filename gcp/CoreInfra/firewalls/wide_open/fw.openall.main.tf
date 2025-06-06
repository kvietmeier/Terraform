###===================================================================================###
#
#  File:  fw_openall.main.tf
#  Created By: Karl Vietmeier
#
#  Purpose:  Create Ffirewall rules to allow everything
#
###===================================================================================###
###                        !!!This is a really bad idea!!!                            ###
###                       ----  USE ONLY IN AN EMERGENCY  ----                        ###
###===================================================================================###

###===================================================================================###
###--- Provider
###===================================================================================###
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
#     Variables
###===================================================================================###

###--- Provider Info
variable "region" {
  description = "Region to deploy resources"
}

variable "zone" {
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


###===================================================================================###
#     Create Resources
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
