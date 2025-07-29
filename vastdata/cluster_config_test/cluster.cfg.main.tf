###===================================================================================###
# VAST Data – Cluster Resource Deployment for Demo/POC
#
# Description:
# This Terraform `main.tf` file provisions core VAST Data resources on a GCP cluster,
# enabling functional evaluation or proof-of-concept deployments. It defines:
#
# - VIP Pool creation:
#     - `sharesPool` for protocol services (role: PROTOCOLS)
#     - `targetPool` for replication (role: REPLICATION)
# - NFS view policy and export path configuration
# - S3-compatible view and bucket configuration
# - Policy-based access controls (NFS and S3)
# - DNS service setup for protocol-based VIP resolution
#
# Features:
# - Uses modular variable input from `.tfvars` or external sources
# - Generates multiple NFS views dynamically via `count`
# - Supports named S3 views with user-level bucket ownership
# - Builds view policies with permission assignment per VIP Pool
#
# Notes:
# - View policies require NFS/SMB ACLs even for S3-only deployments
# - `depends_on` ensures proper resource ordering for VIP and DNS services
#
# Required:
# - Valid `vastdata.GCPCluster` provider configuration must be declared separately
# - Input variable definitions must match those referenced here
###===================================================================================###

###===================================================================================###
#   VIP Pools
###===================================================================================###
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

###===================================================================================###
#   NFS Configuration
###===================================================================================###

###--- Policies
resource "vastdata_view_policy" "nfs_default_policy" {
  provider          = vastdata.GCPCluster
  name              = var.nfs_default_policy_name
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

###--- Views
resource "vastdata_view" "nfs_views" {
  count      = var.num_views
  provider   = vastdata.GCPCluster
  policy_id  = vastdata_view_policy.nfs_default_policy.id
  path       = "/${var.path_name}${count.index + 1}"
  protocols  = var.protocols
  create_dir = var.create_dir
}


###===================================================================================###
#   S3 Configuration
###===================================================================================###

###--- Policies

resource "vastdata_view_policy" "s3_default_policy" {
  provider                 = vastdata.GCPCluster
  name                     = var.s3_default_policy_name
  flavor                   = var.s3_flavor
  s3_special_chars_support = var.s3_special_chars_support
  
  # Common values
  use_auth_provider  = var.use_auth_provider
  auth_source        = var.auth_source
  access_flavor      = var.access_flavor
  
  # Required NFS squash/no-squash settings - will fail apply without these
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


# This is a "user" policy!  It gets associated to a user.
resource "vastdata_s3_policy" "s3policy_user_policy1" {
  provider = vastdata.GCPCluster
  name     = var.s3_user_policy_name
  policy   = file("${path.module}/${var.s3_policy1_file}")
  enabled  = true
}

###--- Views
resource "vastdata_view" "s3_view" {
  provider                  = vastdata.GCPCluster
  policy_id                 = vastdata_view_policy.s3_default_policy.id
  name                      = var.s3_view_name
  bucket                    = var.s3_bucket_name
  path                      = var.s3_view_path
  protocols                 = var.s3_view_protocol
  create_dir                = var.s3_view_create_dir
  allow_s3_anonymous_access = var.s3_view_allow_s3_anonymous
  bucket_owner              = var.s3_default_owner
  #tenant                    = var.s3_default_tenant
  
  # Need a local user for owner
  depends_on = [vastdata_user.users]
  
}


###===================================================================================###
#   Misc Custer Configuration
###===================================================================================###

#======================
#  Create DNS Service
#======================
resource "vastdata_dns" "protocol_dns" {
  provider      = vastdata.GCPCluster
  name          = var.dns_name
  vip           = var.dns_vip
  net_type      = var.port_type
  domain_suffix = var.dns_domain_suffix
  enabled       = var.dns_enabled
}
