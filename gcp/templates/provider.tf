###===================================================================================###
#
#  File:  provider.tf
#  Created By: Karl Vietmeier
#
#  Purpose: Configure Provider
# 
###===================================================================================###
###===================================================================================###
#
#  File:  provider.tf
#  Created By: Karl Vietmeier
#
#  Purpose: Configure the GCP Provider TerraForm
# 
#  Google defaults set as Env: vars
#
###===================================================================================###


terraform {
  required_providers {
  google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

# Set these vars
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}