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

# "Instances" Currently not used in IAM role assignments, but reserved for future
# expansion where instance-level permissions or configurations may be needed.
variable "instances" {
  description = "List of VM names with zones"
  type = list(object({
    name = string
    zone = string
  }))
}


variable "user_emails" {
  description = "List of user email addresses to grant access"
  type        = list(string)
}
