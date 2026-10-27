###=============================================================================
###--- Provider
###=============================================================================

terraform {
  required_providers {
    vastdata = {
      source  = "vast-data/vastdata"
      version = ">= 3.2.2"
    }
  }
}

provider "vastdata" {
  username        = var.vast_username
  password        = var.vast_password
  host            = var.vast_host
  port            = var.vast_port
  skip_ssl_verify = var.vast_skip_ssl_verify
  #alias           = "cluster"
}
