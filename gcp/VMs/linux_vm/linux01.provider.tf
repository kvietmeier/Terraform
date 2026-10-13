###===================================================================================###
#
#  File:  linux01.provider.tf
#  Created By: Karl Vietmeier
#
#  Purpose: Configure the GCP Terraform Provider
#
###===================================================================================###


terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}