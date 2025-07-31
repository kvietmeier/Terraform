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

###  Metadata Variables     
variable "cluster_name" {
  description = "Human-readable name for the VAST cluster"
  type        = string
  default     = "vast-demo-cluster"
}

variable "cluster_description" {
  description = "Description of the cluster environment or purpose"
  type        = string
  default     = "Demo cluster for PoC and testing"
}

variable "cluster_region" {
  description = "Physical or cloud region of the cluster"
  type        = string
  default     = "us-central1"
}

variable "cluster_tags" {
  description = "Tags to assign to cluster for organization"
  type        = map(string)
  default     = {
    environment = "dev"
    project     = "vast-poc"
  }
}
