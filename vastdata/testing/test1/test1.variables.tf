###===================================================================================###
#
#  File:  variables.tf
#  Created By: Karl Vietmeier
#
#  Variable definitions with defaults
#
###===================================================================================###










###===================================================================================###
###--- VAST Provider metadata ---###
###===================================================================================###

###--- Provider A
variable "vasta_user" {
  description = "Admin User for VAST"
  default     = "admin"
}

variable "vasta_port" {
  description = "Port VMS is using"
  default     = "443"
}

variable "vasta_passwd" {
  description = "Admin password"
}

variable "vasta_host" {
  description = "Resolvable address of the Cluster"
}

variable "vasta_skip_ssl" {
  description = "Don't check for SSL"
  default     = "true"
}

variable "vasta_validation_mode" {
  description = "Not sure what this does`"
  default     = "warn"
}

variable "vasta_alias" {
  description = "Alias for the cluster"
  default     = "GCPCluster"
}



###--- Provider B
variable "vastb_user" {
  description = "Admin User for VAST"
  default     = "admin"
}

variable "vastb_port" {
  description = "Port VMS is using"
  default     = "443"
}

variable "vastb_passwd" {
  description = "Admin password"
}

variable "vastb_host" {
  description = "Resolvable address of the Cluster"
}

variable "vastb_skip_ssl" {
  description = "Don't check for SSL"
  default     = "true"
}

variable "vastb_validation_mode" {
  description = "Not sure what this does`"
  default     = "warn"
}

variable "vastb_alias" {
  description = "Alias for the cluster"
  default     = "RemoteCluster"
}