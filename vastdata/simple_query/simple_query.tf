###===================================================================================###
#
#  File:        testapply.main.tf
#  Author:      Karl Vietmeier
#
#  Description:
#  Lightweight Terraform configuration used to verify authentication with a 
#  VAST Data cluster. This script performs a basic read operation by retrieving 
#  metadata for the default tenant, allowing you to:
#
#    - Confirm provider credentials and connectivity
#    - Validate SSL and host configuration
#    - Troubleshoot access issues before applying full deployments
#
#  Usage:
#    terraform apply -auto-approve -var-file=testapply.terraform.tfvars
#
#  Notes:
#    - Uses the VAST provider with alias `GCPCluster`
#    - Defaults are provided for rapid testing
#
###===================================================================================###

###===================================================================================###
###                       Confgure VAST Cluster Provider                              ### 


terraform {
  required_providers {
    vastdata = {
      source  = "vast-data/vastdata"
      version = "1.6.8"
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

###===================================================================================
# Provider Configuration Variables
###===================================================================================

variable "vast_username" {
  description = "Username for VAST Data API access"
  type        = string
}

variable "vast_password" {
  description = "Password for VAST Data API access"
  type        = string
  sensitive   = true
}

variable "vast_host" {
  description = "VAST cluster hostname or IP address"
  type        = string
}

variable "vast_port" {
  description = "VAST cluster API port"
  type        = string
  default     = "443"
}

variable "vast_skip_ssl_verify" {
  description = "Skip SSL verification for the VAST provider"
  type        = bool
  default     = true
}

variable "vast_version_validation_mode" {
  description = "API version validation mode (strict, warn, or none)"
  type        = string
  default     = "warn"
}


###===================================================================================###
###                        Query infrastructure resources                             ###

data "vastdata_tenant" "default" {
  provider = vastdata.GCPCluster
  name = "default"
}


###===================================================================================###
###                                  Output Data                                      ###

output "tenant_id" {
  value = data.vastdata_tenant.default.id
}

output "tenant_name" {
  value = data.vastdata_tenant.default.name
}
