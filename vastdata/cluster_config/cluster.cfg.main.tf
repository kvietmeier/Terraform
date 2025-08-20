###===================================================================================###
# VAST Data – Cluster Resource Deployment for Demo/POC
#
# Description:
# This Terraform `main.tf` file provisions core VAST Data resources on a Google Cloud
# cluster, designed for functional evaluation or proof-of-concept (POC) environments.
# It orchestrates key components required for NFS, SMB, and S3 data access.
#
# Provisioned Resources:
# - VIP Pools:
#     - `sharesPool` (role: PROTOCOLS) for NFS/SMB data services
#     - `s3Pool` (role: PROTOCOLS) for S3-compatible services
#     - `targetPool` (role: REPLICATION) for inter-cluster replication
# - View Policies:
#     - NFS default policy with permissions tied to `sharesPool`
#     - S3 default policy with permissions tied to `s3Pool`
# - Views:
#     - Dynamic NFS views generated via `count`
#     - Static S3 view with bucket configuration
# - Policy-based access controls and DNS configuration for protocol resolution
#
# Features:
# - Automatically computes VIP ranges based on cluster node count
# - Supports multi-protocol deployments (NFS + S3) via distinct pools
# - Centralized pool references through `locals` for simplified configuration
# - Ensures ordered resource creation using `depends_on` where necessary
#
# Notes:
# - `sharesPool` and `s3Pool` must both be defined in `var.vip_pools` (names must match)
# - View policies require NFS/SMB ACLs even for S3-only deployments
# - Provider configuration (`vastdata.GCPCluster`) must be declared outside this file
# - Input variables must align with module references and `.tfvars` inputs
###===================================================================================###


###===================================================================================###
#   VIP Pools - Protocol and Replication
###===================================================================================###

resource "vastdata_vip_pool" "protocols" {
  provider = vastdata.GCPCluster

  for_each = local.protocols_pools

  name        = each.value.name
  subnet_cidr = each.value.subnet_cidr
  role        = each.value.role

  ip_ranges {
    start_ip = each.value.start_ip
    end_ip   = each.value.end_ip
  }

  gw_ip       = try(each.value.gateway, null)
  domain_name = try(each.value.dns_name, null)
  
  # DNS needs to be configured before VIP Pools
  depends_on  = [vastdata_dns.protocol_dns]
}


resource "vastdata_vip_pool" "replication" {
  provider = vastdata.GCPCluster

  for_each = local.replication_pools

  name        = each.value.name
  subnet_cidr = each.value.subnet_cidr
  role        = each.value.role

  ip_ranges {
    start_ip = each.value.start_ip
    end_ip   = each.value.end_ip
  }

  gw_ip       = try(each.value.gateway, null)
  domain_name = try(each.value.dns_name, null)
  
  # DNS needs to be configured before VIP Pools
  depends_on  = [vastdata_dns.protocol_dns]
}


###===================================================================================###
#   NFS Configuration
###===================================================================================###

###--- NFS Default View Policy
resource "vastdata_view_policy" "nfs_basic_policy" {
  provider          = vastdata.GCPCluster
  name              = var.nfs_basic_policy_name

  flavor            = var.flavor
  use_auth_provider = var.use_auth_provider
  auth_source       = var.auth_source
  access_flavor     = var.access_flavor

  nfs_no_squash  = var.nfs_no_squash
  nfs_read_write = var.nfs_read_write
  nfs_read_only  = var.nfs_read_only
  smb_read_write = var.smb_read_write
  smb_read_only  = var.smb_read_only

  vippool_permissions {
    # Reference the sharesPool resource dynamically
    vippool_id          = vastdata_vip_pool.protocols[local.sharespool_key].id
    vippool_permissions = var.vippool_permissions
  }
}

###--- NFS Views
# NFS views are automatically tied to cluster size:
# - One view per node (count = var.number_of_nodes)
# - Adjust logic in locals if different ratio is required

resource "vastdata_view" "nfs_views" {
  provider   = vastdata.GCPCluster

  # Automatically create one view per node
  count      = var.number_of_nodes

  policy_id  = vastdata_view_policy.nfs_basic_policy.id
  path       = "/${var.path_name}${count.index + 1}"
  protocols  = var.protocols
  create_dir = var.create_dir
}

###===================================================================================###
#   S3 Configuration
###===================================================================================###

###--- S3 Standard View Policy
resource "vastdata_view_policy" "s3_basic_policy" {
  provider = vastdata.GCPCluster
  name     = var.s3_basic_policy_name
  flavor   = var.s3_flavor

  s3_special_chars_support = var.s3_special_chars_support
  use_auth_provider        = var.use_auth_provider
  auth_source              = var.auth_source
  access_flavor            = var.access_flavor

  # Need these for some reason
  nfs_no_squash  = var.nfs_no_squash
  nfs_read_write = var.nfs_read_write
  nfs_read_only  = var.nfs_read_only
  smb_read_write = var.smb_read_write
  smb_read_only  = var.smb_read_only

  vippool_permissions {
    # Reference the s3Pool resource dynamically
    vippool_id          = vastdata_vip_pool.protocols[local.s3pool_key].id
    vippool_permissions = var.vippool_permissions
  }
}


###--- Create all S3 views from map
resource "vastdata_view" "s3_views" {
  for_each = local.s3_views

  provider                  = vastdata.GCPCluster
  policy_id                 = each.value.policy_id
  name                      = each.value.name
  bucket                    = each.value.bucket
  path                      = each.value.path
  protocols                 = each.value.protocols
  create_dir                = each.value.create_dir
  bucket_owner              = each.value.bucket_owner
  allow_s3_anonymous_access = lookup(each.value, "allow_s3_anonymous_access", false)

  depends_on = [vastdata_user.users]
}


###--- User S3 Policies

# Allow-all S3 policy (broad permissions)
resource "vastdata_s3_policy" "s3policy_user_allowall" {
  provider = vastdata.GCPCluster
  name     = var.s3_allowall_policy_name
  policy   = file("${path.module}/${var.s3_allowall_policy_file}")
  enabled  = true
}

/*
Disable for now, as detailed policy is not provided
# Detailed S3 policy (fine-grained permissions)
resource "vastdata_s3_policy" "s3policy_user_detailed" {
  provider = vastdata.GCPCluster
  name     = var.s3_detailed_policy_name
  policy   = file("${path.module}/${var.s3_detailed_policy_file}")
  enabled  = true
}
*/

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

