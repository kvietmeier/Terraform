###===================================================================================###
#
#  File:  provider.tf
#  Created By: Karl Vietmeier
#
#  Purpose: Configure the GCP TerraForm Provider 
# 
###===================================================================================###


terraform {
  required_providers {
  google = {
      source  = "hashicorp/google"
      version = "4.74.0"
    }
  }
}

# Set these vars
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}