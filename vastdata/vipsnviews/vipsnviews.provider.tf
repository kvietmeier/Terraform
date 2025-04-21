###===================================================================================###
#
#  File:  vipsnviews.provider.tf
#  Created By: Karl Vietmeier
#
###===================================================================================###

terraform {
  required_providers {
    vastdata = {
      source  = "vast-data/vastdata"
      version = "1.6.0"
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