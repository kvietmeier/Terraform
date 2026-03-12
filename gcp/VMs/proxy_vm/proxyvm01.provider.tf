###===================================================================================###
#
#  File:  provider.tf
#  Created By: Karl Vietmeier
#
#  Purpose: Configure the GCP TerraForm Provider 
# 
###===================================================================================###

terraform {
  backend "gcs" {
    bucket  = "clouddev-itdesk124-tfstate"
    prefix  = "terraform/state/proxyvm01"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.9.0"
    }
    #google-beta = {
    #  source  = "hashicorp/google-beta"
    #  version = ">= 5.9.0"
    #}
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}
