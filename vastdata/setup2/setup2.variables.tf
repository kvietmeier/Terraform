###===================================================================================###
#
#  File:  variables.tf
#  Created By: Karl Vietmeier
#
#  Variable definitions with defaults
#
###===================================================================================###



###===================================================================================###
###--- Cluster Resources
###===================================================================================###

###--- Policy Parameters

variable "policy_flavor" {
  description = "What protocol"
  default     = "NFS"
}



###--- View Policy Parameters
variable "vip_pool_existing" {
  description = "VIP Pool already created in the cluster"
  default     = "protocolsPool"
}

variable "view_policy_name" {
  description = "Name of the policy"
}

variable "dir_create" {
  description = "Create the directory?"
  default     = "true"
}

variable nfs_clients {
  description = "A list of IPs for NFS clients"
  type        = list(string)
}

###--- View Parameters
variable "share_path" {
  description = "Fileshare Path"
}

variable view_protocols {
  description = "Supported NFS versions"
  type        = list(string)
}


variable "variable" {
  description = "foobar"
  default     = "foobar_val"
}

variable "variable" {
  description = "foobar"
  default     = "foobar_val"
}


variable "variable" {
  description = "foobar"
  default     = "foobar_val"
}



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