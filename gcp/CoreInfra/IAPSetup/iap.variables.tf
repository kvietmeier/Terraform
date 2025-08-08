###===================================================================================###
#
#  File:  variables.tf
#  Created By: Karl Vietmeier
#
#  Variable definitions with defaults
#
###===================================================================================###

### Provider Information
variable "region" {
  description = "Region to deploy resources"
}

variable "zone" {
  description = "Availbility Zone"
}

variable "project_id" {
  description = "GCP Project ID"
}



### IAP Configuration
variable "instance_names" {
  description = "Name of the target VM instance"
  type        = list(string)
}

variable "user_emails" {
  description = "List of user email addresses to grant access"
  type        = list(string)
}
