##===================================================================================
# File:        vipsnviews.variables.tf
# Created By:  Karl Vietmeier
#
# Description: Terraform variable definitions for VAST VIPs and views.
#===================================================================================

#------------------------------------------------------------------------------
# Provider Configuration Variables
#------------------------------------------------------------------------------

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

#------------------------------------------------------------------------------
# VIP Pool Configuration Variables
#------------------------------------------------------------------------------

variable "vip1_name" {
  description = "Name of the first VIP Pool"
  type        = string
}

variable "vip2_name" {
  description = "Name of the second VIP Pool"
  type        = string
}

variable "cidr" {
  description = "CIDR block for VIP subnets"
  type        = string
}

variable "gw1" {
  description = "Gateway for the first subnet"
  type        = string
}

variable "gw2" {
  description = "Gateway for the second subnet"
  type        = string
}

variable "vip1_startip" {
  description = "Start IP for VIP Pool 1"
  type        = string
}

variable "vip1_endip" {
  description = "End IP for VIP Pool 1"
  type        = string
}

variable "vip2_startip" {
  description = "Start IP for VIP Pool 2"
  type        = string
}

variable "vip2_endip" {
  description = "End IP for VIP Pool 2"
  type        = string
}

#------------------------------------------------------------------------------
# View Policy and View Configuration Variables
#------------------------------------------------------------------------------

variable "role1" {
  description = "Role name for VIP Pool 1"
  type        = string
}

variable "role2" {
  description = "Role name for VIP Pool 2"
  type        = string
}

variable "policy_name" {
  description = "Name of the VAST view policy"
  type        = string
}

variable "num_views" {
  description = "Number of views to create"
  type        = number
}

variable "path_name" {
  description = "Base path name for views"
  type        = string
}
