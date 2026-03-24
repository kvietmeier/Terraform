###===================================================================================###
#                             Provider Configuration
###===================================================================================###

#  File:  provider.tf
#  Created By: Karl Vietmeier
#  Purpose: Configure the GCP Provider TerraForm
#  Google defaults set as Env: vars
#  Using remote state in GCS bucket with prefix for organization and project

terraform {
  backend "gcs" {
    bucket  = "clouddev-itdesk124-tfstate"
    prefix  = "terraform/state/spoke1-pc"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.9.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 5.9.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}
