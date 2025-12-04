###===================================================================================
### VAST Data Cluster Input Variables
### All variables for main.tf and users.tf
###===================================================================================###

###===================================================================================
###--- Provider Configuration
###===================================================================================
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

###===================================================================================
###--- Cluster Node & VIP Configuration
###===================================================================================
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

###===================================================================================
###--- DNS Configuration 
###===================================================================================
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

###===================================================================================
###--- NFS/SMB View Policy Settings
###===================================================================================
###===================================================================================
###--- NFS/SMB View Policy Settings
###===================================================================================
variable "nfs_policies" {
  type = map(object({
    name                                   : string,             # <-- Added
    flavor                                 : string,
    access_flavor                          : string,             # <-- Added
    allowed_characters                     : string,             # <-- Added
    nfs_read_write                         : set(string),
    nfs_read_only                          : set(string),
    nfs_no_squash                          : set(string),
    nfs_root_squash                        : set(string),        # <-- Added
    nfs_posix_acl                          : bool,               # <-- Added
    smb_read_write                         : set(string),
    smb_read_only                          : set(string),
    gid_inheritance                        : string,             # <-- Added
    enable_access_to_snapshot_dir_in_subdirs : bool              # <-- Added
  }))
  default = {}
}


variable "s3_policies" {
  type = map(object({
    name                                   : string,             # <-- Added
    flavor                                 : string,
    access_flavor                          : string,             # <-- Added
    allowed_characters                     : string,             # <-- Added
    s3_read_write                          : set(string),
    s3_read_only                           : set(string),
    s3_flavor_allow_free_listing           : bool,               # <-- Added
    s3_flavor_detect_full_pathname         : bool,               # <-- Added
    s3_special_chars_support               : bool,               # <-- Added
    #special_chars                          : bool,               # (Keep this if it's required by the provider schema)
    gid_inheritance                        : string,             # <-- Added
    enable_access_to_snapshot_dir_in_subdirs : bool              # <-- Added
  }))
  default = {}
}

### Remove?
variable "s3_allowall_policy_name" {
  type = string
}

variable "s3_allowall_policy_file" {
  type = string
}



###===================================================================================
###--- NFS/SMB Views
###===================================================================================
variable "file_views_config" {
  description = "Map of NFS/SMB views to create with their configuration"
  type = map(object({
    name       : string
    path       : string
    protocols  : list(string)
    create_dir : bool
    policy     : string
  }))
  default = {}
}

variable "s3_views_config" {
  description = "Map of S3 views to create with their configuration"
  type = map(object({
    name                      : string
    bucket                    : string
    path                      : string
    protocols                 : list(string)
    create_dir                : bool
    policy                    : string
    bucket_owner              : string
    allow_s3_anonymous_access : optional(bool)
  }))
  default = {}
}

###===================================================================================
###--- Users, Groups, Tenants
###===================================================================================
variable "groups" {
  type = map(object({
    gid = number
  }))
  default = {}
}

variable "users" {
  type = map(object({
    uid                  : number
    leading_group_name   : string
    supplementary_groups : list(string)
    allow_create_bucket  : optional(bool, false)
    allow_delete_bucket  : optional(bool, false)
    s3_superuser         : optional(bool, false)
  }))
  default = {}
}

variable "tenants" {
  description = "Map of tenants with their allowed client IP ranges"
  type = map(object({
    client_ip_ranges = list(object({
      start_ip : string
      end_ip   : string
    }))
  }))
  default = {}
}

###===================================================================================
###--- PGP Keys
###===================================================================================
variable "s3pgpkey" {
  type = string
}

variable "pgp_key_users" {
  type    = list(string)
  default = ["s3user1", "dbuser1"]
}

###===================================================================================
###--- Active Directory / LDAP
###===================================================================================
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

###===================================================================================
###--- Authentication / Access Settings
###===================================================================================
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

###===================================================================================
###--- Other Settings
###===================================================================================
variable "num_views" {
  type    = number
  default = 0
}

variable "create_dir" {
  type    = bool
  default = true
}

variable "path_name" {
  type    = string
  default = "nfsview"
}
