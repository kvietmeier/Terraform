###===================================================================================###
#
#  File:  vipsnviews.variables.tf
#  Created By: Karl Vietmeier
#
#   Variables
# 
###===================================================================================###


# Provider variables
variable "vast_username" {}
variable "vast_password" {}
variable "vast_host" {}
variable "vast_port" { default = "443" }
variable "vast_skip_ssl_verify" { default = true }
variable "vast_version_validation_mode" { default = "warn" }

# Variables not allowed for Alias
#variable "vast_provider_alias" { default = "GCPCluster" }

# Infrastructure variables
variable "vip1_name" {}
variable "vip2_name" {}
variable "cidr" {}
variable "gw1" {}
variable "gw2" {}
variable "vip1_startip" {}
variable "vip1_endip" {}
variable "vip2_startip" {}
variable "vip2_endip" {}
variable "role1" {}
variable "role2" {}
variable "policy_name" {}
variable "num_views" {}
variable "path_name" {}