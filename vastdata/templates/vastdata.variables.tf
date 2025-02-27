###===================================================================================###
#
#  File:  vastdata.variables.tf
#  Created By: Karl Vietmeier
#
#  These are going to be the same for every configuration.
#   
###===================================================================================###



###===================================================================================###
###--- Cluster Resources
###===================================================================================###














###===================================================================================###
###--- VAST Provider metadata
###===================================================================================###

variable "vast_version" {
  description = "Provider version"
  default     = "1.3.3"
}

variable "vast_user" {
  description = "Admin User for VAST"
  default     = "admin"
}

variable "vast_port" {
  description = "Port VMS is using"
  default     = "443"
}

variable "vast_passwd" {
  description = "Admin password"
}

variable "vast_host" {
  description = "Resolvable address of the Cluster"
}

variable "skip_ssl" {
  description = "Don't check for SSL"
  default     = "true"
}

variable "validation_mode" {
  description = "Not sure what this does`"
  default     = "warn"
}
