###===================================================================================###
# VAST Data – Demo/POC Configuration Input Variables (.tfvars)
#
# This file provides input values for provisioning a VAST Data cluster with:
# - NFS and S3 view policies and view configurations
# - Local user and group mappings for centralized access control
#
# Notes:
# - Users are dual-provisioned as POSIX IDs and local VMS administrative logins.
###===================================================================================###

###===================================================================================###
# Provider Configuration
###===================================================================================###
vast_username                = "admin"
vast_password                = "123456"
vast_host                    = "10.105.28.66"
vast_port                    = "443"
vast_skip_ssl_verify         = true
vast_version_validation_mode = "warn"

###===================================================================================###
#   VIP Pool Configuration
###===================================================================================###
number_of_nodes = 4

###===================================================================================###
#   Common View Policy Settings
###===================================================================================###
flavor            = "MIXED_LAST_WINS"
use_auth_provider = true
auth_source       = "RPC_AND_PROVIDERS"
access_flavor     = "ALL"

###===================================================================================###
#   NFS Settings
###===================================================================================###

###---  NFS View Policy Settings
nfs_basic_policy_name   = "nfs-view-policy"
vippool_permissions     = "RW"
nfs_basic_policy_flavor = "MIXED_LAST_WINS" 
nfs_no_squash           = ["*"]
nfs_read_write          = ["*"]
nfs_read_only           = []
smb_read_write          = []
smb_read_only           = []

###---  File View Settings (Fixed Typos & Expanded 01 through 10)
file_views_config = {
  labview01 = {
    name       = "view01"
    path       = "/view01"
    protocols  = ["NFS"]
    create_dir = true
  }
  labview02 = {
    name       = "view02"
    path       = "/view02"
    protocols  = ["NFS"]
    create_dir = true
  }
  labview03 = {
    name       = "view03"
    path       = "/view03"
    protocols  = ["NFS"]
    create_dir = true
  }
  labview04 = {
    name       = "view04"
    path       = "/view04"
    protocols  = ["NFS"]
    create_dir = true
  }
  labview05 = {
    name       = "view05"
    path       = "/view05"
    protocols  = ["NFS"]
    create_dir = true
  }
}

/* 
file_views_config = {
  labview01 = {
    name       = "gns-dst"
    path       = "/gns-dst"
    protocols  = ["NFS"]
    create_dir = true
  }
 */


###===================================================================================###
#   S3 Settings
###===================================================================================###

###--- Basic S3 View Policy Settings
s3_basic_policy_name     = "StandardS3Policy"
s3_basic_policy_flavor   = "S3_NATIVE" 
s3_special_chars_support = true

###--- S3 View Settings
s3_views_config = {
  s3_view01 = {
    name                      = "s3view01"
    bucket                    = "bucket01"
    path                      = "/s3view01"
    protocols                 = ["S3"]
    create_dir                = true
    bucket_owner              = "s3user1"
    allow_s3_anonymous_access = false
  }
  s3_view02 = {
    name                      = "s3view02"
    bucket                    = "bucket02"
    path                      = "/s3view02"
    protocols                 = ["S3"]
    create_dir                = true
    bucket_owner              = "s3user1"
    allow_s3_anonymous_access = false
  }
  db = {
    name                      = "vastdb_view"
    bucket                    = "vastdb01"
    path                      = "/vastdb"
    protocols                 = ["S3", "DATABASE"]
    create_dir                = true
    bucket_owner              = "dbuser1"
    allow_s3_anonymous_access = true
  }
}

###===================================================================================###
#   User/Group Settings using maps
###===================================================================================###
s3_allowall_policy_file = "../../policies/s3Policy-VastAllowAll.json"
s3_allowall_policy_name = "s3_user_AllowAll"

s3pgpkey = "../../secrets/s3_pgp_key.asc"
pgp_key_users = [
  "dbuser1",
  "s3user1",
  "s3user2",
  "vastuser01",
  "vastuser02",
  "vastuser03",
  "vastuser04",
  "vastuser05"
]

groups = {
  s3users  = { gid = 1000 }
  nfsusers = { gid = 1100 }
  allusers = { gid = 1200 }
}

users = {
  vastuser01 = {
    uid                  = 2111
    leading_group_name   = "allusers"
    supplementary_groups = ["s3users", "nfsusers"]
    allow_create_bucket  = true
    allow_delete_bucket  = true
    s3_superuser         = true
  }
  vastuser02 = {
    uid                  = 2112
    leading_group_name   = "allusers"
    supplementary_groups = ["s3users", "nfsusers"]
    allow_create_bucket  = true
    allow_delete_bucket  = true
    s3_superuser         = true
  }
  vastuser03 = {
    uid                  = 2113
    leading_group_name   = "allusers"
    supplementary_groups = ["s3users", "nfsusers"]
    allow_create_bucket  = true
    allow_delete_bucket  = true
    s3_superuser         = true
  }
  vastuser04 = {
    uid                  = 2114
    leading_group_name   = "allusers"
    supplementary_groups = ["s3users", "nfsusers"]
    allow_create_bucket  = true
    allow_delete_bucket  = true
    s3_superuser         = true
  }
  vastuser05 = {
    uid                  = 2115
    leading_group_name   = "allusers"
    supplementary_groups = ["s3users", "nfsusers"]
    allow_create_bucket  = true
    allow_delete_bucket  = true
    s3_superuser         = true
  }
  s3user1 = {                    # Pushed down to keep index sequence pristine
    uid                  = 2121
    leading_group_name   = "allusers"
    supplementary_groups = ["nfsusers", "s3users"]
    allow_create_bucket  = true
    allow_delete_bucket  = true
    s3_superuser         = true
  }
  s3user2 = {                    # Pushed down to keep index sequence pristine
    uid                  = 2122
    leading_group_name   = "allusers"
    supplementary_groups = ["nfsusers", "s3users"]
    allow_create_bucket  = true
    allow_delete_bucket  = true
    s3_superuser         = true
  }
  dbuser1 = {                    # Pushed down to keep index sequence pristine
    uid                  = 2123
    leading_group_name   = "allusers"
    supplementary_groups = ["nfsusers", "s3users"]
    allow_create_bucket  = true
    allow_delete_bucket  = true
    s3_superuser         = true
  }
}


###===================================================================================###
#   DNS Settings
###===================================================================================###
# Set DNS VIP to match subnet cidr and updsare forwarder if needed.
dns_name          = "vastdns"
dns_vip           = "10.105.28.250"
port_type         = "NORTH_PORT"
dns_domain_suffix = "vastlab.org"
dns_enabled       = true
#vip_gateway       = "172.1.4.1"
