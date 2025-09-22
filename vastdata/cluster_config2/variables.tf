###===================================================================================###
# Input Variables for VAST Data Cluster – Demo/POC
###===================================================================================###

#--------------------------------------
# Provider Configuration
#--------------------------------------
variable "vast_username" {
  type = string
}

variable "vast_password" {
  type      = string
  sensitive = true
}

variable "vast_host" {
  type = string
}

variable "vast_port" {
  type    = number
  default = 443
}

variable "vast_skip_ssl_verify" {
  type    = bool
  default = false
}

variable "vast_version_validation_mode" {
  type    = string
  default = "strict"
}

#--------------------------------------
# Cluster Node & VIP Configuration
#--------------------------------------
variable "number_of_nodes" {
  type = number
}

variable "vips_per_node" {
  type = number
}

variable "vip_pools" {
  type = map(object({
    name        = string
    start_ip    = string
    gateway     = string
    subnet_cidr = number
    role        = string
    dns_name    = optional(string)
  }))
}

variable "protocols" {
  type    = list(string)
  default = ["NFS", "SMB", "S3"]
}

variable "flavor" {
  description = "Default flavor for view policies"
  type        = string
  default     = "MIXED_LAST_WINS"
}

#--------------------------------------
# DNS Configuration
#--------------------------------------
variable "dns_name" {
  type = string
}

variable "dns_vip" {
  type = string
}

variable "dns_domain_suffix" {
  type = string
}

variable "port_type" {
  type    = string
  default = "NORTH_PORT"
}

variable "dns_enabled" {
  type    = bool
  default = true
}

#--------------------------------------
# NFS/SMB View Policy Settings
#--------------------------------------
variable "nfs_basic_policy_name" {
  type = string
}

variable "nfs_no_squash" {
  type    = set(string)
  default = []
}

variable "nfs_read_write" {
  type    = set(string)
  default = ["*"]
}

variable "nfs_read_only" {
  type    = set(string)
  default = []
}

variable "smb_read_write" {
  type    = set(string)
  default = ["*"]
}

variable "smb_read_only" {
  type    = set(string)
  default = []
}

variable "vippool_permissions" {
  type    = string
  default = "RW"
}

#--------------------------------------
# NFS View Settings
#--------------------------------------
variable "num_views" {
  type    = number
  default = 0
}

variable "path_name" {
  type    = string
  default = "nfsview"
}

variable "create_dir" {
  type    = bool
  default = true
}

variable "nfs_views_config" {
  description = "Map of NFS views to create with their configuration"
  type = map(object({
    name       : string
    path       : string
    protocols  : list(string)
    create_dir : bool
  }))
  default = {
    nfsview01 = {
      name       = "nfsview01"
      path       = "/nfs01"
      protocols  = ["NFS"]
      create_dir = true
    }
  }
}





#--------------------------------------
# S3 View & Policy Settings
#--------------------------------------
variable "s3_basic_policy_name" {
  type = string
}

variable "s3_flavor" {
  type    = string
  default = "S3_NATIVE"
}

variable "s3_special_chars_support" {
  type    = bool
  default = false
}

variable "s3_views_config" {
  type = map(object({
    name                      = string
    bucket                    = string
    path                      = string
    protocols                 = list(string)
    create_dir                = bool
    bucket_owner              = string
    allow_s3_anonymous_access = optional(bool)
  }))
}

variable "s3_allowall_policy_name" {
  type = string
}

variable "s3_allowall_policy_file" {
  type = string
}

#--------------------------------------
# Users, Groups, Tenants
#--------------------------------------
variable "groups" {
  type = map(object({
    gid = number
  }))
}

variable "users" {
  type = map(object({
    uid                  = number
    leading_group_name   = string
    supplementary_groups = list(string)
    allow_create_bucket  = optional(bool, false)
    allow_delete_bucket  = optional(bool, false)
    s3_superuser         = optional(bool, false)
  }))
}

variable "tenants" {
  description = "Map of tenants with their allowed client IP ranges"
  type = map(object({
    client_ip_ranges = list(object({
      start_ip = string
      end_ip   = string
    }))
  }))
}


#--------------------------------------
# PGP Keys
#--------------------------------------
variable "s3pgpkey" {
  type = string
}

variable "pgp_key_users" {
  type    = list(string)
  default = ["s3user1", "dbuser1"]
}

#--------------------------------------
# Active Directory / LDAP
#--------------------------------------
variable "ou_name" {
  type = string
}

variable "ad_ou" {
  type = string
}

variable "use_ad" {
  type    = bool
  default = true
}

variable "bind_dn" {
  type = string
}

variable "bindpw" {
  type      = string
  sensitive = true
}

variable "ldap" {
  type    = bool
  default = true
}

variable "ad_domain" {
  type = string
}

variable "method" {
  type    = string
  default = "simple"
}

variable "query_mode" {
  type    = string
  default = "tokenGroups"
}

variable "use_tls" {
  type    = bool
  default = true
}

variable "ldap_urls" {
  type    = list(string)
  default = []
}

#--------------------------------------
# Authentication / Access Settings
#--------------------------------------
variable "use_auth_provider" {
  type    = bool
  default = true
}

variable "auth_source" {
  type    = string
  default = "RPC_AND_PROVIDERS"
}

variable "access_flavor" {
  type    = string
  default = "ALL"
}
