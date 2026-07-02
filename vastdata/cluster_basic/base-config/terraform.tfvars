###===================================================================================###
# VAST Data – Demo/POC Configuration Input Variables (.tfvars)
#
# This file provides input values for provisioning a VAST Data cluster with:
# - Multiple VIP Pools (PROTOCOLS, REPLICATION, VAST_CATALOG roles)
# - NFS and S3 view policies and view configurations
# - Local user and group mappings for centralized access control
#
# Notes:
# - Dropped multi-tenant isolation overhead to allow straight-line lab access.
# - Users are now dual-provisioned as POSIX IDs and local VMS administrative logins.
###===================================================================================###

###===================================================================================###
# Provider Configuration
###===================================================================================###
vast_username                = "admin"
vast_password                = "123456"
vast_host                    = "10.129.12.10"
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

/* ###---  File View Settings (Fixed Typos & Expanded 01 through 10)
file_views_config = {
  labview01 = {
    name       = "labuser01"
    path       = "/labuser01"
    protocols  = ["NFS"]
    create_dir = true
  }
  labview02 = {
    name       = "labuser02"
    path       = "/labuser02"
    protocols  = ["NFS"]
    create_dir = true
  }
  labview03 = {
    name       = "labuser03"
    path       = "/labuser03"
    protocols  = ["NFS"]
    create_dir = true
  }
  labview04 = {
    name       = "labuser04"
    path       = "/labuser04"
    protocols  = ["NFS"]
    create_dir = true
  }
  labview05 = {
    name       = "labuser05"
    path       = "/labuser05"
    protocols  = ["NFS"]
    create_dir = true
  }
  labview06 = {
    name       = "labuser06"
    path       = "/labuser06"
    protocols  = ["NFS"]
    create_dir = true
  }
  labview07 = {
    name       = "labuser07"
    path       = "/labuser07"
    protocols  = ["NFS"]
    create_dir = true
  }
  labview08 = {                 # Fixed structural key naming from labview0
    name       = "labuser08"
    path       = "/labuser08"
    protocols  = ["NFS"]
    create_dir = true
  }
  labview09 = {                 # New Clone User Add
    name       = "labuser09"
    path       = "/labuser09"
    protocols  = ["NFS"]
    create_dir = true
  }
  labview10 = {                 # New Clone User Add
    name       = "labuser10"
    path       = "/labuser10"
    protocols  = ["NFS"]
    create_dir = true
  }
}
 */

file_views_config = {
  labview01 = {
    name       = "gns-dst"
    path       = "/gns-dst"
    protocols  = ["NFS"]
    create_dir = true
  }


###===================================================================================###
#   S3 Settings
###===================================================================================###

###--- Basic S3 View Policy Settings
s3_basic_policy_name     = "StandardS3Policy"
s3_basic_policy_flavor   = "S3_NATIVE" 
s3_special_chars_support = true

###--- S3 View Settings
s3_views_config = {
  s3 = {
    name                      = "s3view01"
    bucket                    = "bucket01"
    path                      = "/s3"
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
  "labuser01",
  "labuser02",
  "labuser03",
  "labuser04",
  "labuser05",
  "labuser06",
  "labuser07",
  "labuser08",
  "labuser09",
  "labuser10"
]

groups = {
  s3users  = { gid = 1000 }
  nfsusers = { gid = 1100 }
  allusers = { gid = 1200 }
}

users = {
  labuser01 = {
    uid                  = 2111
    leading_group_name   = "allusers"
    supplementary_groups = ["s3users", "nfsusers"]
    allow_create_bucket  = true
    allow_delete_bucket  = true
    s3_superuser         = true
  }
  labuser02 = {
    uid                  = 2112
    leading_group_name   = "allusers"
    supplementary_groups = ["s3users", "nfsusers"]
    allow_create_bucket  = true
    allow_delete_bucket  = true
    s3_superuser         = true
  }
  labuser03 = {
    uid                  = 2113
    leading_group_name   = "allusers"
    supplementary_groups = ["s3users", "nfsusers"]
    allow_create_bucket  = true
    allow_delete_bucket  = true
    s3_superuser         = true
  }
  labuser04 = {
    uid                  = 2114
    leading_group_name   = "allusers"
    supplementary_groups = ["s3users", "nfsusers"]
    allow_create_bucket  = true
    allow_delete_bucket  = true
    s3_superuser         = true
  }
  labuser05 = {
    uid                  = 2115
    leading_group_name   = "allusers"
    supplementary_groups = ["s3users", "nfsusers"]
    allow_create_bucket  = true
    allow_delete_bucket  = true
    s3_superuser         = true
  }
  labuser06 = {
    uid                  = 2116
    leading_group_name   = "allusers"
    supplementary_groups = ["s3users", "nfsusers"]
    allow_create_bucket  = true
    allow_delete_bucket  = true
    s3_superuser         = true
  }
  labuser07 = {
    uid                  = 2117
    leading_group_name   = "allusers"
    supplementary_groups = ["s3users", "nfsusers"]
    allow_create_bucket  = true
    allow_delete_bucket  = true
    s3_superuser         = true
  }
  labuser08 = {
    uid                  = 2118
    leading_group_name   = "allusers"
    supplementary_groups = ["s3users", "nfsusers"]
    allow_create_bucket  = true
    allow_delete_bucket  = true
    s3_superuser         = true
  }
  labuser09 = {                  # Continuous incremental UID assignment
    uid                  = 2119
    leading_group_name   = "allusers"
    supplementary_groups = ["s3users", "nfsusers"]
    allow_create_bucket  = true
    allow_delete_bucket  = true
    s3_superuser         = true
  }
  labuser10 = {                  # Continuous incremental UID assignment
    uid                  = 2120
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
  dbuser1 = {                    # Pushed down to keep index sequence pristine
    uid                  = 2122
    leading_group_name   = "allusers"
    supplementary_groups = ["nfsusers", "s3users"]
    allow_create_bucket  = true
    allow_delete_bucket  = true
    s3_superuser         = true
  }
}

###===================================================================================###
#   REMOVED SYSTEM BOUNDARIES (Tenant definitions commented out to use default plane)
###===================================================================================###
/* tenants = {
...
*/