###===================================================================================###
# VAST Data Cluser basic setup for demo/POC
#
# Notes:
# --role: PROTOCOLS | REPLICATION | VAST_CATALOG
#
# This file defines:
# - VAST provider connection settings
# - Two VIP Pools:
#     - sharesPool (role: PROTOCOLS)
#     - targetPool (role: REPLICATION)
# - Shared network settings
# - NFS view policy configuration
# - DNS
###===================================================================================###

# ======================
# VIP Pools
# ======================
resource "vastdata_vip_pool" "protocols" {
  provider     = vastdata.GCPCluster
  name         = var.vip1_name
  domain_name  = var.dns_shortname
  role         = var.role1
  subnet_cidr  = var.cidr
  gw_ip        = var.gw1
  ip_ranges {
    start_ip = var.vip1_startip
    end_ip   = var.vip1_endip
  }

  depends_on = [vastdata_dns.protocol_dns]
}

resource "vastdata_vip_pool" "replication" {
  provider     = vastdata.GCPCluster
  name         = var.vip2_name
  role         = var.role2
  subnet_cidr  = var.cidr
  gw_ip        = var.gw2
  ip_ranges {
    start_ip = var.vip2_startip
    end_ip   = var.vip2_endip
  }
}

# ======================
# NFS View Policy
# ======================
resource "vastdata_view_policy" "vpolicy1" {
  provider          = vastdata.GCPCluster
  name              = var.policy_name
  #vip_pools         = [vastdata_vip_pool.protocols.id]
  flavor            = var.flavor
  use_auth_provider = var.use_auth_provider
  auth_source       = var.auth_source
  access_flavor     = var.access_flavor

  # Required NFS squash/no-squash settings
  nfs_no_squash     = var.nfs_no_squash
  nfs_read_write    = var.nfs_read_write
  nfs_read_only     = var.nfs_read_only
  smb_read_write    = var.smb_read_write
  smb_read_only     = var.smb_read_only
  
  vippool_permissions {
    vippool_id          = vastdata_vip_pool.protocols.id
    vippool_permissions = var.vippool_permissions
  }
}

# ======================
# S3 View Policy - standard defaults
# ======================
/* 
resource "vast_view_policy" "s3_default_policy" {
  provider           = vastdata.GCPCluster
  name               = var.policy_name
  enable_s3          = var.enable_s3
  enable_nfs         = var.enable_nfs
  enable_smb         = var.enable_smb
  s3_all_buckets     = var.s3_all_buckets
  s3_root_access     = var.s3_root_access
  use_ldap_auth      = var.use_ldap_auth
}
*/

resource "vastdata_s3_policy" "s3policy" {
  name     = "s3policy1"
  provider = vastdata.GCPCluster
  policy   = <<EOT
        {
   "Version":"2012-10-17",
   "Statement":[
      {
         "Effect":"Allow",
         "Action": "s3:ListAllMyBuckets",
         "Resource":"*"
      },
      {
         "Effect":"Allow",
         "Action":["s3:ListObjects","s3:GetBucketLocation"],
         "Resource":"arn:aws:s3:::DOC-EXAMPLE-BUCKET1"
      },
      {
         "Effect":"Allow",
         "Action":[
            "s3:PutObject",
            "s3:PutObjectAcl",
            "s3:GetObject",
            "s3:GetObjectAcl",
            "s3:DeleteObject"
         ],
         "Resource":"arn:aws:s3:::DOC-EXAMPLE-BUCKET1/*"
      }
   ]
}
        EOT
  enabled = true
}

# ======================
# Views
# ======================

### - NFS
resource "vastdata_view" "nfs_views" {
  count      = var.num_views
  provider   = vastdata.GCPCluster
  policy_id  = vastdata_view_policy.vpolicy1.id
  path       = "/${var.path_name}${count.index + 1}"
  protocols  = var.protocols
  create_dir = var.create_dir
}

### - S3
resource "vast_view" "s3_view" {
  provider           = vastdata.GCPCluster
  name               = var.s3_view_name
  path               = var.s3_view_path
  policy             = vastdata_s3_policy.s3policy.id
  protocols          = var.s3_view_protocol
  #tenant             = var.s3tenant
  create_dir         = var.s3_view_create_dir
  allow_s3_anonymous = var.s3_view_allow_s3_anonymous
}


# ======================
#  Create DNS Service
# ======================
resource "vastdata_dns" "protocol_dns" {
  provider      = vastdata.GCPCluster
  name          = var.dns_name
  vip           = var.dns_vip
  net_type      = var.port_type
  domain_suffix = var.dns_domain_suffix
  enabled       = var.dns_enabled
}
