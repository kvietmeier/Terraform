terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.9.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 5.9.0"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = ">= 2.3.0"
    }
  }

  # Uncomment and set prefix for remote state (do not reuse CoreInfra state prefixes).
  # backend "gcs" {
  #   bucket = "clouddev-itdesk124-tfstate"
  #   prefix = "terraform/state/configure-project"
  # }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}
