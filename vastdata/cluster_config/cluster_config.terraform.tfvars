###===================================================================================###
# VAST Data – Configuration Settings for VIP Pools, NFS/S3 Views, DNS, and Identity
#
# Description:
# This `.tfvars` file provides input values for deploying a VAST Data cluster 
# in a demo or proof-of-concept environment. It configures critical settings for:
#
# - Two VIP Pools:
#     - sharesPool (role: PROTOCOLS)
#     - targetPool (role: REPLICATION)
# - NFS and S3 view policy and export configuration
# - POSIX-style tenant, user, and group definitions
# - DNS configuration (including VIP and domain settings)
# - Active Directory integration (disabled by default in this file)
#
# Highlights:
# - Creates 3 NFS views with full read-write/no-squash access
# - Defines one S3 view with default policy and ownership
# - Users are assigned with leading and supplementary GIDs
# - All IPs are open by default for simplified testing
# - AD join is configured but disabled; LDAP URL is statically defined
#
# Warning:
# - Credentials (e.g., bindpw, vast_password) are included in clear text for testing
#   and should **not** be used in production environments.
# - This file should be secured or excluded from version control if used beyond PoC.
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
# VIP Pool 1 Configuration
###===================================================================================###
vip1_name      = "sharesPool"
vip1_startip   = "33.20.1.11"
vip1_endip     = "33.20.1.13"
#vip1_endip     = "33.20.1.21"
gw1            = "33.20.1.1"
role1          = "PROTOCOLS"
dns_shortname  = "sharespool"

###===================================================================================###
# VIP Pool 2 Configuration
###===================================================================================###
vip2_name      = "targetPool"
vip2_startip   = "33.21.1.11"
vip2_endip     = "33.21.1.13"
#vip2_endip     = "33.21.1.21"
gw2            = "33.21.1.1"
role2          = "REPLICATION"

###===================================================================================###
#   Shared Network Settings
###===================================================================================###

cidr           = "24"

###===================================================================================###
#   Common View Policy Settings
###===================================================================================###
flavor                  = "MIXED_LAST_WINS"
use_auth_provider       = true
auth_source             = "RPC_AND_PROVIDERS"
access_flavor           = "ALL"



###===================================================================================###
#   NFS View Policy Settings
###===================================================================================###
nfs_default_policy_name = "nfs-view-policy"
nfs_no_squash       = ["0.0.0.0/0"]
nfs_read_write      = ["0.0.0.0/0"]
nfs_read_only       = []
smb_read_write      = []
smb_read_only       = []
vippool_permissions = "RW"


###===================================================================================###
#   NFS View Settings
###===================================================================================###
num_views         = 3
path_name         = "nfs_share_"
protocols         = ["NFS"]
create_dir        = true

###===================================================================================###
#   S3 Settings
###===================================================================================###
#tenant             = "default-tenant"

###--- User View Policy in json
s3_policy1_file            = "s3Policy-allowall.json"

###--- Default S3 View Policy Settings
s3_default_policy_name   = "DefaultS3Policy"
s3_flavor                = "S3_NATIVE"
s3_special_chars_support = true


###--- Default S3 View Settings
s3_view_name               = "s3bucket01"
s3_view_path               = "/s3bucket01"
s3_bucket_name             = "bucket01"
s3_view_protocol           = ["S3"]
s3_enable                  = true
s3_default_owner           = "s3user1"

###===================================================================================###
# DNS Settings
###===================================================================================###
dns_name          = "vastdns"
dns_vip           = "172.1.4.110"
port_type         = "NORTH_PORT"
dns_domain_suffix = "busab.org"
dns_enabled       = true
#vip_gateway       = "172.1.4.1"


###===================================================================================###
# User/Tenant Settings
###===================================================================================###

tenants = [
  {
    name             = "sardukar"
    client_ip_ranges = ["0.0.0.0/0"]
  },
  {
    name             = "gowachin"
    client_ip_ranges = ["0.0.0.0/0"]
  },
  {
    name             = "fremen"
    client_ip_ranges = ["0.0.0.0/0"]
  }
]

groups = [
  { name = "s3users", gid  = 1000 },
  { name = "nfsusers", gid = 1100 },
  { name = "allusers", gid = 1200 }
]

users = [
  {
    name                 = "nfsuser1"
    uid                  = 2111
    leading_group_name   = "allusers"
    supplementary_groups = ["s3users", "nfsusers"]
  },
  {
    name                 = "s3user1"
    uid                  = 2112
    leading_group_name   = "s3users"
    supplementary_groups = ["allusers", "nfsusers"]
  }
]


###===================================================================================###
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
