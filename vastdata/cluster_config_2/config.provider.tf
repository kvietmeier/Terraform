###===================================================================================###
# VAST Data – Terraform Provider Configuration
#
# Sets up the VAST provider (v1.6.8) with GCP cluster connection settings.
# Uses input variables for credentials, host info, and SSL options.
# Alias: GCPCluster
###===================================================================================###

terraform {
  required_providers {
    vastdata = {
      source  = "vast-data/vastdata"
      version = "2.1.1"
      #version = "2.0"
    }
  }
}

provider "vastdata" {
  alias                   = "GCPCluster_jpn"
  username                = var.vast_username
  password                = var.vast_password
  host                    = "172.10.13.8"
  port                    = var.vast_port
  skip_ssl_verify         = var.vast_skip_ssl_verify
  version_validation_mode = var.vast_version_validation_mode
}