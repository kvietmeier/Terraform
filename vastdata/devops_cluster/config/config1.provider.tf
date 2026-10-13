###===================================================================================###
# VAST Data – Terraform Provider Configuration
#
# Local state (install_configure.py cleans/reinits this dir each run).
# Auth via TF_VAR_vast_host / TF_VAR_vast_username / TF_VAR_vast_password.
# Alias: GCPCluster
###===================================================================================###

terraform {
  required_providers {
    vastdata = {
      source  = "vast-data/vastdata"
      version = "3.2.2"
    }
  }
}

provider "vastdata" {
  username                = var.vast_username
  password                = var.vast_password
  host                    = var.vast_host
  port                    = var.vast_port
  skip_ssl_verify         = var.vast_skip_ssl_verify
  version_validation_mode = var.vast_version_validation_mode
  alias                   = "GCPCluster"
}
