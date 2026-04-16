###===================================================================================###
#
#  File:  devops01.provider.tf
#  Created By: Karl Vietmeier
#
#  Purpose: Configure the GCP TerraForm Provider 
# 
#  Google defaults set as Env: vars
#
###===================================================================================###


terraform {
  backend "gcs" {
    bucket  = "clouddev-itdesk124-tfstate"
    prefix  = "terraform/state/vpn-connection" # Unique path for the VPN project
  }
  required_providers {
  google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}