###===================================================================================###
#
#  File:  variables.tf
#  Created By: Karl Vietmeier
#
#  Variable definitions with defaults
#
###===================================================================================###

variable "region" {
  description = "Region to deploy resources"
}

variable "zone" {
  description = "Availbility Zone"
}

variable "project_id" {
  description = "GCP Project ID"
}

variable "vpc_name" {
  description = "Default VPC"
  default     = "default"
}

variable "subnet_range_domain_controllers" {
  default = "10.0.0.0/28"
}

variable "subnet_range_resources" {
  default = "10.0.1.0/24"
}

variable "project_id" {
  default = "vpc-project-123"
}