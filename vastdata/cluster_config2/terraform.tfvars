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
###===================================================================================###
number_of_nodes = 3
vips_per_node   = 1

vip_pools = {
  vip1 = {
    name        = "sharesPool"
    start_ip    = "33.20.1.11"
    gateway     = "33.20.1.1"
    subnet_cidr = 24
    role        = "PROTOCOLS"
    dns_name    = "sharespool"
  }

  vip2 = {
    name        = "targetPool"
    start_ip    = "33.21.1.11"
    gateway     = "33.21.1.1"
    subnet_cidr = 24
    role        = "REPLICATION"
  }

  vip3 = {
    name        = "s3Pool"
    start_ip    = "33.22.1.11"
    gateway     = "33.22.1.1"
    subnet_cidr = 24
    role        = "PROTOCOLS"
    dns_name    = "s3pool"
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

###---  NFS View Policy Settings
nfs_basic_policy_name = "nfs-view-policy"
nfs_no_squash         = ["0.0.0.0/0"]
nfs_read_write        = ["0.0.0.0/0"]
nfs_read_only         = []
smb_read_write        = []
smb_read_only         = []
vippool_permissions   = "RW"

###---  NFS View Settings
#num_views         = 5      # Override: create 5 views (uncomment if you don't want num_views = num_nodes)
path_name         = "nfs_"
protocols         = ["NFS"]
create_dir        = true



###===================================================================================###
#   S3 Settings
###===================================================================================###

###--- Basic S3 View Policy Settings
s3_basic_policy_name     = "StandardS3Policy"
s3_flavor                = "S3_NATIVE"
s3_special_chars_support = true


s3_views_config = {
  s3 = {
    name                      = "s3view01"
    bucket                    = "bucket01"
    path                      = "/s3buckets"
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
#   DNS Settings
###===================================================================================###
dns_name          = "vastdns"
dns_vip           = "172.1.4.110"
port_type         = "NORTH_PORT"
dns_domain_suffix = "busab.org"
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
# Can't use TLS for some reason - 
use_ad          = false
use_tls         = false
ldap            = false
# Optional: if you're not using DNS discovery
ldap_urls       = ["ldap://172.20.16.3"]