###===================================================================================###
#
#  File:  bind.provider.tf
#  Created By: Karl Vietmeier
#
#  Purpose: Tiny Ubuntu GCE BIND9 conditional forwarder for VAST DNS testing
#           when Cloud DNS private forwarding zones cannot be updated.
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
