###===================================================================================###
###                       Confgure VAST Cluster Provider   
###
###  Standardized provider configuration for VAST Data Terraform Provider
###  This file is included in all other Terraform modules to ensure consistent
###  provider configuration and variable declarations.
###  
###  Simple Version
###
###  Notes:
###  - The provider block is configured to read from environment variables for sensitive information.
###  - The provider version is pinned to ensure compatibility with the VAST Data Terraform Provider.
###===================================================================================###
# 1. Provider Source & Version
terraform {
  required_providers {
    vastdata = {
      source  = "vast-data/vastdata"
      version = "3.2.2"
    }
  }
}

# 2. Variable Declarations (Enables TF_VAR_ shell variable mapping)
variable "vast_username" {
  type      = string
  default   = null
  sensitive = true
}

variable "vast_password" {
  type      = string
  default   = null
  sensitive = true
}

variable "vast_api_token" {
  type      = string
  default   = null
  sensitive = true
}

variable "vast_skip_ssl_verify" {
  type    = bool
  default = true
}

variable "vast_version_validation_mode" {
  type    = string
  default = "warn"
}

# 3. Provider Configuration
provider "vastdata" {
  # Auto-reads VASTDATA_HOST, VASTDATA_PORT, VASTDATA_TENANT from shell
  username                = var.vast_username
  password                = var.vast_password
  api_token               = var.vast_api_token
  skip_ssl_verify         = var.vast_skip_ssl_verify
  version_validation_mode = var.vast_version_validation_mode
}