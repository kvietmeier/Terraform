###===================================================================================###
# VAST Data – VIP Pool, NFS/S3 View, DNS, and Identity Configuration (POC)
#
# This file declares input variables for provisioning a VAST Data cluster.
# - VIP Pools (PROTOCOLS, REPLICATION, S3)
# - NFS/S3 View Policies and Views
# - DNS, Tenant, User, and Group configurations
#
# Populate values via `terraform.tfvars`.
###===================================================================================###

#------------------------------------------------------------------------------ 
# VIP Pool Configuration
#------------------------------------------------------------------------------
variable "vip_pools" {
  description = "Map of VIP pool configurations"
  type = map(object({
    name        = string
    start_ip    = string
    end_ip      = string
    role        = string           # Must be: PROTOCOLS, REPLICATION, or VAST_CATALOG
    subnet_cidr = optional(number) # CIDR for the subnet (default: 24)
    dns_name    = optional(string) # Optional DNS shortname
    gateway     = optional(string) # Optional gateway IP, used as gw_ip in resource
  }))
}

#------------------------------------------------------------------------------ 
# View/Policy Common Settings
#------------------------------------------------------------------------------
variable "flavor" {
  description = "Specifies the NFS view policy flavor"
  type        = string
  default     = "MIXED_LAST_WINS"
}

variable "use_auth_provider" {
  description = "Enable external authentication provider"
  type        = bool
  default     = true
}

variable "auth_source" {
  description = "Authentication source (e.g., RPC_AND_PROVIDERS)"
  type        = string
  default     = "RPC_AND_PROVIDERS"
}

variable "access_flavor" {
  description = "Access flavor setting"
  type        = string
  default     = "ALL"
}

variable "vippool_permissions" {
  description = "Permissions for VIP pools (RW/RO)"
  type        = string
  default     = "RW"
}

#------------------------------------------------------------------------------ 
# NFS View Policy & View Configuration
#------------------------------------------------------------------------------
variable "nfs_default_policy_name" {
  description = "Name of the default NFS view policy"
  type        = string
}

variable "nfs_no_squash" {
  description = "CIDRs/IPs with no-root-squash access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "nfs_read_write" {
  description = "CIDRs/IPs with read-write access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "nfs_read_only" {
  description = "CIDRs/IPs with read-only access"
  type        = list(string)
  default     = []
}

variable "smb_read_write" {
  description = "Users/groups/IPs with SMB read-write access"
  type        = list(string)
  default     = []
}

variable "smb_read_only" {
  description = "Users/groups/IPs with SMB read-only access"
  type        = list(string)
  default     = []
}

# View creation
variable "num_views" {
  description = "Number of views to create"
  type        = number
}

variable "path_name" {
  description = "Base path name for views"
  type        = string
}

variable "protocols" {
  description = "Protocols to enable for views"
  type        = list(string)
  default     = ["NFS"]
}

variable "create_dir" {
  description = "Create export directory automatically"
  type        = bool
  default     = true
}

#------------------------------------------------------------------------------ 
# S3 View Configuration
#------------------------------------------------------------------------------
variable "s3_default_policy_name" {
  description = "Name of the default S3 view policy"
  type        = string
}

variable "s3_flavor" {
  description = "Flavor for S3 view policy"
  type        = string
  default     = "S3_NATIVE"
}

variable "s3_special_chars_support" {
  description = "Allow special characters in object names"
  type        = bool
  default     = true
}

variable "s3_view_path" {
  description = "Filesystem path for the S3 view"
  type        = string
  default     = "/s3bucket01"
}

variable "s3_view_protocol" {
  description = "Protocol list for S3 view"
  type        = list(string)
  default     = ["S3"]
}

variable "s3_view_name" {
  description = "Name of the S3 view"
  type        = string
  default     = "s3view01"
}

variable "s3_bucket_name" {
  description = "Bucket name for the S3 view"
  type        = string
  default     = "bucket01"
}

variable "s3_default_owner" {
  description = "Owner of the S3 view"
  type        = string
}

variable "s3_use_ldap_auth" {
  description = "Enable LDAP auth for S3"
  type        = bool
  default     = false
}

variable "s3_view_create_dir" {
  description = "Create directory if missing"
  type        = bool
  default     = true
}

variable "s3_view_allow_s3_anonymous" {
  description = "Allow anonymous S3 access"
  type        = bool
  default     = true
}


#------------------------------------------------------------------------------ 
# S3 User Policy Setup
#------------------------------------------------------------------------------
variable "s3_detailed_policy_name" {
  description = "Name of the S3 user policy"
  type        = string
}

variable "s3_detailed_policy_file" {
  description = "Path to the S3 policy JSON file"
  type        = string
}

variable "s3_allowall_policy_name" {
  description = "Name of the S3 user policy"
  type        = string
}

variable "s3_allowall_policy_file" {
  description = "Path to the S3 policy JSON file"
  type        = string
}

#------------------------------------------------------------------------------ 
# User, Group, Tenant Configuration
#------------------------------------------------------------------------------
variable "groups" {
  description = "Map of groups to create"
  type = map(object({
    gid = number
  }))
}

variable "users" {
  description = "Map of users to create"
  type = map(object({
    uid                  = number
    leading_group_name   = string
    supplementary_groups = list(string)
    allow_create_bucket  = optional(bool, false)
    allow_delete_bucket  = optional(bool, false)
    s3_superuser         = optional(bool, false)   # <--- Add this line
  }))
}

variable "tenants" {
  description = "Map of tenants to create"
  type = map(object({
    client_ip_ranges = list(object({
      start_ip = string
      end_ip   = string
    }))
    vippool_ids = optional(list(string))
  }))
}

###--- User Key
variable "s3pgpkey" {
  description = "Path to the PGP public key file for S3 user keys"
  type        = string
}