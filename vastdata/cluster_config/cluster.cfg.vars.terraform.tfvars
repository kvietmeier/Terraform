###===================================================================================###
# VAST Cluster Input Variables – Clean, Readable Map Format
###===================================================================================###

### Provider Configuration
vast_username                = "admin"
vast_password                = "123456"
vast_host                    = "vms"
vast_port                    = "443"
vast_skip_ssl_verify         = true
vast_version_validation_mode = "warn"

### Cluster Settings
number_of_nodes = 3
vips_per_node   = 1

### VIP Pools
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

### Common View Policy Settings
flavor            = "MIXED_LAST_WINS"
use_auth_provider = true
auth_source       = "RPC_AND_PROVIDERS"
access_flavor     = "ALL"

### NFS View Policy Settings
nfs_basic_policy_name = "nfs-view-policy"
nfs_no_squash         = ["0.0.0.0/0"]
nfs_read_write        = ["0.0.0.0/0"]
nfs_read_only         = []
smb_read_write        = []
smb_read_only         = []
vippool_permissions   = "RW"

### NFS View Settings
# num_views = 5      # Optional override: number of NFS views
path_name  = "nfs_"
protocols  = ["NFS"]
create_dir = true

### S3 Settings
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

### DNS Settings
dns_name          = "vastdns"
dns_vip           = "172.1.4.110"
port_type         = "NORTH_PORT"
dns_domain_suffix = "busab.org"
dns_enabled       = true

### Groups
groups = {
  s3users  = { gid = 1000 }
  nfsusers = { gid = 1100 }
  allusers = { gid = 1200 }
}

### Users
users = {
  nfsuser1 = {
    uid                  = 2111
    leading_group_name   = "allusers"
    supplementary_groups = ["s3users", "nfsusers"]
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

### Tenants
tenants = {
  tenant1 = {
    client_ip_ranges = [
      { start_ip = "10.0.0.0", end_ip = "10.0.0.255" },
      { start_ip = "10.0.1.0", end_ip = "10.0.1.255" }
    ]
  }

  tenant2 = {
    client_ip_ranges = [
      { start_ip = "192.168.1.0", end_ip = "192.168.1.255" }
    ]
  }
}

### User S3 Policy Files
s3_allowall_policy_file     = "../policies/s3Policy-VastAllowAll.json"
# s3_detailed_policy_file    = "s3Policy-Detailed.example.json"

### S3 Policy Names
s3_allowall_policy_name     = "s3_user_AllowAll"
# s3_detailed_policy_name    = "s3policy_user_detailed"

### PGP Keys
s3pgpkey   = "../secrets/s3_pgp_key.asc"
pgp_key_users = ["dbuser1", "s3user1"]

###===================================================================================###
# Active Directory
###===================================================================================###
ou_name         = "voc-cluster01"
ad_ou           = "OU=VAST,DC=ginaz,DC=org"
bind_dn         = "CN=Administrator,CN=Users,DC=ginaz,DC=org"
bindpw          = "Chalc0pyr1te!123"
ad_domain       = "ginaz.org"
method          = "simple"
query_mode      = "COMPATIBLE"
use_ad          = false
use_tls         = false
ldap            = false
ldap_urls       = ["ldap://172.20.16.3"]
