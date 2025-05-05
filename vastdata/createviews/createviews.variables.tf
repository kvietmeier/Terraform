###===================================================================================###
#  File:  vipsnviews.variables.tf
#  Created By: Karl Vietmeier
#  Description: Defines variables for VAST Data cluster and resources
###===================================================================================###

###===================================================================================###
###                            VAST Cluster Authentication Variables                  ###
###===================================================================================###

variable "vast_username" {
  description = "Username for authenticating with the VAST Data cluster."
}

variable "vast_password" {
  description = "Password for authenticating with the VAST Data cluster."
}

variable "vast_host" {
  description = "Hostname or IP address of the VAST Data cluster."
}

variable "vast_port" {
  description = "Port used to connect to the VAST Data API."
  default     = "443"
}

variable "vast_skip_ssl_verify" {
  description = "Whether to skip SSL verification for the VAST provider."
  default     = true
}

variable "vast_version_validation_mode" {
  description = "Specifies how to handle version validation (e.g., warn, strict)."
  default     = "warn"
}

###===================================================================================###
###                            VAST Cluster Resource Variables                        ###
###===================================================================================###

variable "vip_pool_existing" {
  description = "The name of the existing VIP Pool to query from the VAST cluster"
  type        = string
}

variable "policy_name" {
  description = "Name for the VAST view policy to be created."
}

variable "view_policy_flavor" {
  description = "The view policy flavor (e.g., MIXED_LAST_WINS, NFS, SMB)."
  default     = "MIXED_LAST_WINS"
}

variable "use_auth_provider" {
  description = "Whether to use an authentication provider."
  default     = true
}

variable "auth_source" {
  description = "The authentication source used by the view policy."
  default     = "RPC_AND_PROVIDERS"
}

variable "access_flavor" {
  description = "Access flavor for the view policy (e.g., ALL, NFS, SMB)."
  default     = "ALL"
}

variable "nfs_no_squash" {
  description = "List of CIDRs that are exempt from NFS root squashing."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "nfs_read_write" {
  description = "List of CIDRs with NFS read/write access."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "nfs_read_only" {
  description = "List of CIDRs with NFS read-only access."
  type        = list(string)
  default     = []
}

variable "smb_read_write" {
  description = "List of users/groups with SMB read/write access."
  type        = list(string)
  default     = []
}

variable "smb_read_only" {
  description = "List of users/groups with SMB read-only access."
  type        = list(string)
  default     = []
}

variable "vippool_permission_mode" {
  description = "Permissions to grant on the VIP pool (e.g., RW, RO)."
  default     = "RW"
}

###===================================================================================###
###                            View Configuration Variables                           ###
###===================================================================================###

variable "num_views" {
  description = "Number of NFS views to create."
}

variable "path_name" {
  description = "Base name for the paths used in NFS views."
}

###===================================================================================###
###                            Convert Data to variables                              ###
###===================================================================================###

locals {
  protocols_vip_pool_id        = data.vastdata_vip_pool.protocolsVIP.id
  protocols_vip_pool_name      = data.vastdata_vip_pool.protocolsVIP.name
  protocols_vip_pool_tenant_id = data.vastdata_vip_pool.protocolsVIP.tenant_id
  protocols_vip_pool_cluster   = data.vastdata_vip_pool.protocolsVIP.cluster
}
