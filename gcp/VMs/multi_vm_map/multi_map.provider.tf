###===================================================================================###
#                              Provider Configuration
###===================================================================================###
#  File:  provider.tf
#  Created By: Karl Vietmeier
#
#  Purpose: Configure the GCP TerraForm Provider 
#  
#  Created By: Karl Vietmeier
#  Purpose: Configure the GCP Provider TerraForm
#  Google defaults set as Env: vars
#  Using remote state in GCS bucket with prefix for organization and project
#    bucket  = "clouddev-itdesk124-tfstate"
#    prefix  = "terraform/state/CHANGEME"
###===================================================================================###
terraform {
  backend "gcs" {
    bucket  = "clouddev-itdesk124-tfstate"
    prefix  = "terraform/state/clientvms-1"
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
