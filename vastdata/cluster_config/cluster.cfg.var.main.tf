###===================================================================================###
# VAST Data Cluster Input Variables
# All variables for main.tf and users.tf
# Logical headers for readability, maps split on multiple lines
###===================================================================================###

#========================
# Provider / Auth
#========================
variable "vast_username"                { type = string }
variable "vast_password"                { type = string }
variable "vast_host"                    { type = string }
variable "vast_port"                    { type = string }
variable "vast_skip_ssl_verify"         { type = bool }
variable "vast_version_validation_mode" { type = string }

#========================
# VIP Pools
#========================
variable "number_of_nodes" { type = number }
variable "vips_per_node"   { type = number }

variable "vip_pools" {
  type = map(object({
    name        = string
    start_ip    = string
    gateway     = optional(string)
    subnet_cidr = number
    role        = string
    dns_name    = optional(string)
  }))
}

#========================
# View / Policy Settings
#========================
variable "flavor"            { type = string }
variable "use_auth_provider" { type = bool }
variable "auth_source"       { type = string }
variable "access_flavor"     { type = string }

variable "nfs_basic_policy_name" { type = string }
variable "nfs_no_squash"         { type = list(string) }
variable "nfs_read_write"        { type = list(string) }
variable "nfs_read_only"         { type = list(string) }
variable "smb_read_write"        { type = list(string) }
variable "smb_read_only"         { type = list(string) }
variable "vippool_permissions"   { type = string }

variable "s3_basic_policy_name"     { type = string }
variable "s3_flavor"                { type = string }
variable "s3_special_chars_support" { type = bool }

variable "s3_views_config" {
  type = map(object({
    name                      = string
    bucket                    = string
    path                      = string
    protocols                 = list(string)
    create_dir                = bool
    bucket_owner              = string
    allow_s3_anonymous_access = optional(bool, false)
  }))
}

#========================
# Users / Groups / Tenants / Keys
#========================
variable "groups" {
  type = map(object({ gid = number }))
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
  type = map(object({
    client_ip_ranges = list(object({ start_ip = string, end_ip = string }))
    vippool_ids      = optional(list(string))
  }))
}

variable "s3pgpkey"     { type = string }
variable "pgp_key_users" { type = list(string) }

#========================
# Active Directory / LDAP
#========================
variable "ou_name"      { type = string }
variable "ad_ou"        { type = string }
variable "bind_dn"      { type = string }
variable "bindpw"       { type = string }
variable "ad_domain"    { type = string }
variable "method"       { type = string }
variable "query_mode"   { type = string }
variable "use_ad"       { type = bool }
variable "use_tls"      { type = bool }
variable "ldap"         { type = bool }
variable "ldap_urls"    { type = list(string) }

#========================
# DNS Settings
#========================
variable "dns_name"          { type = string }
variable "dns_vip"           { type = string }
variable "port_type"         { type = string }
variable "dns_domain_suffix" { type = string }
variable "dns_enabled"       { type = bool }
