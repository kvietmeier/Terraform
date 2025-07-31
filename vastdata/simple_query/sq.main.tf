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
#  You can use this file as a starting point for more complex configurations. It has 
#  been designed to be simple and straightforward, focusing on the essential elements
#  to start working with VAST Data and create a foundation for further development.
#
###===================================================================================###


###===================================================================================###
###                        Query infrastructure resources                             ###

data "vastdata_tenant" "default" {
  provider = vastdata.GCPCluster
  name = "default"
}


###===================================================================================###
###                           Start Adding Resources                                  ###

