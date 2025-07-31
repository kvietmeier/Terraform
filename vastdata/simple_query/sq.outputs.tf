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
###          ###===================================================================================###
#                             Output Data                                             #
###===================================================================================###

output "cluster_name" {
  description = "The human-readable name of the VAST cluster"
  value       = var.cluster_name
}

output "cluster_description" {
  description = "Description of the cluster environment or purpose"
  value       = var.cluster_description
}

output "cluster_region" {
  description = "Physical or cloud region of the cluster"
  value       = var.cluster_region
}

output "cluster_tags" {
  description = "Tags assigned to the cluster for organization"
  value       = var.cluster_tags
}

output "tenant_name" {
  description = "The name of the default tenant in the VAST cluster"
  value       = data.vastdata_tenant.default.name
}

output "tenant_id" {
  description = "The ID of the default tenant in the VAST cluster"
  value       = data.vastdata_tenant.default.id
}
