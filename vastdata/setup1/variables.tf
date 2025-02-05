###===================================================================================###
#
#  File:  variables.tf
#  Created By: Karl Vietmeier
#
#  Variable definitions with defaults
#
###===================================================================================###

###--- VAST Provider metadata
variable "vast_user" {
  description = "Admin User for VAST"
  default     = "admin"
}

variable "vast_port" {
  description = "Port VMS is using"
}

variable "vast_passwd" {
  description = "Admin password"
}

variable "vast_host" {
  description = "resolvable address of VMS admin port"
}

variable "skip_ssl" {
  description = "Don't check for SSL"
  default     = "true"
}

variable "validation_mode" {
  description = "Not sure what this does`"
  default     = "warn"
}

