###===================================================================================###
# VAST Data – Demo/POC Configuration Input Variables (.tfvars)
#
# This file provides input values for provisioning a VAST Data cluster with:
# - Multiple VIP Pools (PROTOCOLS, REPLICATION, VAST_CATALOG roles)
# - NFS and S3 view policies and view configurations
# - Tenant, user, and group mappings for access control
# - DNS service setup for cluster networking
# - Active Directory integration settings (disabled by default)
#
# Notes:
# - Designed for demo or proof-of-concept deployments; IPs and credentials
#   are simplified and should be secured for production use.
# - VIP Pools include optional gateways and DNS names.
# - Supports multiple NFS views and a single S3 view with custom policies.
# - Users can have POSIX groups and bucket creation/deletion permissions.
###===================================================================================###

###===================================================================================###
# Provider Configuration
###===================================================================================###

vast_username                = "admin"
vast_password                = "123456"
vast_host                    = "vms"
vast_port                    = "443"
vast_skip_ssl_verify         = true
vast_version_validation_mode = "warn"


###===================================================================================###
#   VIP Pool Configuration (see locals for explanation)
#
#   Cant use Cloud Routing for Replication - need to pull from subnet.
#
###===================================================================================###
number_of_nodes = 3
vips_per_node   = 2

vip_pools = {
  vip1 = {
    name        = "sharesPool"
    start_ip    = "33.20.1.10"
    gateway     = "33.20.1.1"
    subnet_cidr = 24
    role        = "PROTOCOLS"
    dns_name    = "protocol"
  }
  
  # Create Repliction Pool during install
  /*vip2 = {
    name        = "ReplicationPool"
    start_ip    = "172.9.1.100"
    gateway     = "172.10.5.1"
    subnet_cidr = 24
    role        = "REPLICATION"
  }
 */

  vip3 = {
    name        = "s3Pool"
    start_ip    = "33.21.1.10"
    gateway     = "33.21.1.1"
    subnet_cidr = 24
    role        = "PROTOCOLS"
    dns_name    = "s3"
  } 
}


###===================================================================================###
#   Common View Policy Settings
###===================================================================================###
flavor                  = "MIXED_LAST_WINS"
use_auth_provider       = true
auth_source             = "RPC_AND_PROVIDERS"
access_flavor           = "ALL"



###===================================================================================###
#   NFS Settings
###===================================================================================###

nfs_policies = {
  voc_standard_nfs = {
    name                    = "nfs-voc-policy"
    flavor                  = "NFS"
    access_flavor           = "ALL"
    allowed_characters      = "LCD"
    nfs_read_write          = ["*"]
    nfs_read_only           = []  
    nfs_no_squash           = ["*"]
    nfs_root_squash         = []
    nfs_posix_acl           = false
    smb_read_write          = []
    smb_read_only           = []
    gid_inheritance         = "LINUX"
    enable_access_to_snapshot_dir_in_subdirs = true
  }
}

###---  File View Settings

file_views_config = {
  fileview01 = {
    name       = "nfs"
    path       = "/pak_nfs"
    protocols  = ["NFS"]
    create_dir = true
    policy     = "voc_standard_nfs"  
  }

  fileview02 = {
    name       = "pak_origin"
    path       = "/pak_origin"
    protocols  = ["NFS"]
    create_dir = true
    policy     = "voc_standard_nfs"  
  }
/*
  fileview03 = {
    name       = "nfs_3"
    path       = "/nfs_3"
    protocols  = ["NFS"]
    create_dir = true
  }

  fileview04 = {
    name       = "nfs_4"
    path       = "/nfs_4"
    protocols  = ["NFS"]
    create_dir = true
  }
  
  fileview05 = {
    name       = "nfs_5"
    path       = "/nfs_5"
    protocols  = ["NFS"]
    create_dir = true
  } */
}


###===================================================================================###
#   S3 Settings
###===================================================================================###

s3_policies = {
  voc_standard_s3 = {
    name                              = "s3-voc-policy"
    flavor                            = "S3_NATIVE"
    access_flavor                     = "ALL"
    allowed_characters                = "LCD"
    s3_read_write                     = ["*"]
    s3_read_only                      = []
    s3_flavor_allow_free_listing      = false
    s3_flavor_detect_full_pathname    = false
    s3_special_chars_support          = true
    #special_chars                     = true 
    gid_inheritance                   = "LINUX"
    enable_access_to_snapshot_dir_in_subdirs = true
  }
}


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
    policy                    = "voc_standard_s3"  
  }
  db = {
    name                      = "vastdb_view"
    bucket                    = "vastdb01"
    path                      = "/vastdb"
    protocols                 = ["S3", "DATABASE"]
    create_dir                = true
    bucket_owner              = "dbuser1"
    allow_s3_anonymous_access = true
    policy                    = "voc_standard_s3"  
  }
}


###===================================================================================###
#   DNS Settings
###===================================================================================###
# Set DNS VIP to match subnet cidr and updsare forwarder if needed.
dns_name          = "vastdns"
dns_vip           = "172.9.1.250"
port_type         = "NORTH_PORT"
dns_domain_suffix = "vastohio.com"
dns_enabled       = true
#vip_gateway       = "172.1.4.1"


###===================================================================================###
#   User/Tenant Settings using maps
###===================================================================================###


#- User View Polices json files
s3_allowall_policy_file = "../policies/s3Policy-VastAllowAll.json"
#s3_detailed_policy_file = "s3Policy-Detailed.example.json"

# Policy names
s3_allowall_policy_name = "s3_user_AllowAll"
#s3_detailed_policy_name = "s3policy_user_detailed"

###--- Keys
s3pgpkey = "../secrets/s3_pgp_key.asc"
pgp_key_users = ["dbuser1", "s3user1"]


groups = {
  s3users  = { gid = 1000 }
  nfsusers = { gid = 1100 }
  allusers = { gid = 1200 }
}

users = {
  nfsuser1 = {
    uid                  = 2111
    leading_group_name   = "allusers"
    supplementary_groups = ["s3users", "nfsusers"]
    # allow_create_bucket and allow_delete_bucket default to false
  }

  s3user1 = {
    uid                  = 2112
    leading_group_name   = "allusers"
    supplementary_groups = ["nfsusers", "s3users"]
    allow_create_bucket  = true
    allow_delete_bucket  = true
    s3_superuser         = true
  }
  dbuser1 = {
    uid                  = 2113
    leading_group_name   = "allusers"
    supplementary_groups = ["nfsusers", "s3users"]
    allow_create_bucket  = true
    allow_delete_bucket  = true
    s3_superuser         = true
  }
}

tenants = {
  tenant1 = {
    client_ip_ranges = [
      { start_ip = "10.10.0.0", end_ip = "10.10.0.254" }
    ]
  }
  tenant2 = {
    client_ip_ranges = [
      { start_ip = "192.168.0.0", end_ip = "192.168.0.254" }
    ]
  }
}


###==================================================================================###
# Active Directory
###===================================================================================###
ou_name         = "voc-cluster01"
ad_ou           = "OU=VAST,DC=ginaz,DC=org "
bind_dn         = "CN=Administrator,CN=Users,DC=ginaz,DC=org"
bindpw          = "Chalc0pyr1te!123"
ad_domain       = "ginaz.org"
method          = "simple"
query_mode      = "COMPATIBLE"
use_ad          = true
use_tls         = false
ldap            = false
# Optional: if you're not using DNS discovery
# Can't use TLS for some reason - 
ldap_urls       = ["ldap://172.20.16.3"]






/*
# Default NFS view policy 5.4.2
resource "vastdata_view_policy" "default" {
  provider = vastdata.GCPCluster_1

  name                = "default"
  flavor              = "NFS"
  access_flavor       = "ALL"
  allowed_characters  = "LCD"
  apple_sid           = true
  auth_source         = "RPC"

  disable_handle_lease                     = false
  disable_read_lease                       = false
  disable_write_lease                      = false
  enable_access_to_snapshot_dir_in_subdirs = true
  enable_listing_of_snapshot_dir           = false
  enable_snapshot_lookup                   = true
  enable_visibility_of_snapshot_dir        = false
  expose_id_in_fsid                        = false
  gid_inheritance                          = "LINUX"
  inherit_parent_mode_bits                 = false
  internal                                 = false
  is_s3_default_policy                     = false

  nfs_case_insensitive            = false
  nfs_enforce_tls                 = false
  nfs_enforce_tls_relaxed         = false
  nfs_minimal_protection_level    = "SYSTEM"
  nfs_read_write                  = ["*"]
  nfs_root_squash                 = ["*"]
  nfs_posix_acl                   = false
  nfs_return_open_permissions     = false

  path_length                     = "LCD"

  s3_flavor_allow_free_listing     = false
  s3_flavor_detect_full_pathname   = false
  s3_special_chars_support         = true
  s3_read_write                    = ["*"]

  smb_directory_mode               = 755
  smb_file_mode                    = 644
  smb_is_ca                        = false
  smb_read_write                   = ["*"]

  sync                             = "SYNCED"
}
*/