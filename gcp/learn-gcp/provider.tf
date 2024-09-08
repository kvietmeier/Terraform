###===================================================================================###
#
#  File:  provider.tf
#  Created By: Karl Vietmeier
#
#  Purpose: Configure GCP Provider
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

# Configuration Options:
provider "google" {
  project = "karlv-landingzone"
  region  = "us-west2"
  zone    = "us-west2-a"
  impersonate_service_account = "karlv-servacct-tf@karlv-landingzone.iam.gserviceaccount.com"
}
