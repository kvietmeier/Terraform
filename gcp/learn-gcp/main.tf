### main.tf for GCP

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
  project = "karlv-landingzone"
}

resource "google_compute_network" "vpc_tf" {
  name = "terraform-network"
}
