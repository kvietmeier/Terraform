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

# Terraform version and required providers
terraform {
    required_version = ">=1.4"

    required_providers {
      vastdata = {
        source  = "vast-data/vastdata"
        version = "1.6.0"
    }
  }
}

# VAST Data Provider Configuration
provider vastdata {
  # Set values in .tfvars
  username                = var.vast_user
  port                    = var.vast_port
  password                = var.vast_passwd
  host                    = var.vast_host
  skip_ssl_verify         = var.skip_ssl
  version_validation_mode = var.validation_mode
  alias                   = "GCPCluster"
}

###===================================================================================###
###                            VAST Cluster Provider Variables                        ###

variable "vast_user" {
  description = "Username for the VAST Cluster"
  type        = string
  default     = "admin"
}

variable "vast_port" {
  description = "Port used to connect to the VAST Cluster"
  type        = number
  default     = 443
}

variable "vast_passwd" {
  description = "Password for the VAST Cluster"
  type        = string
  default     = "123456"
}

variable "vast_host" {
  description = "Hostname or IP address of the VAST Cluster"
  type        = string
  default     = "vms"
}

variable "skip_ssl" {
  description = "Boolean to skip SSL certificate verification"
  type        = bool
  default     = false
}

variable "validation_mode" {
  description = "Mode to use for provider version validation"
  type        = string
  default     = "strict"
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
