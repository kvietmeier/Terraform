###===================================================================================###
#
#  File:  fw.variables.tf
#  Created By: Karl Vietmeier
#
#  Variable definitions with defaults
#
###===================================================================================###

###--- Provider Info
variable "region" {
  description = "Region to deploy resources"
}

variable "zone" {
  description = "Availbility Zone"
}

variable "project_id" {
  description = "GCP Project ID"
}


###--- VPC Setup
variable "vpc_name" {
  description = "Name of VPC"
  type        = string
  default     = "default"
}


variable "rule_direction" {
  description = "Ingress or Egress"
  type        = string
  default     = "INGRESS"
}

variable "rule_priority" {
  description = "Priority on stack"
  type        = string
  default     = "500"
}

variable ingress_filter {
  description = "A list of IPs and CIDR ranges to allow"
  type        = list(string)
}
