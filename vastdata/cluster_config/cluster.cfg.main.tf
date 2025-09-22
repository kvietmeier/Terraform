###===================================================================================###
# VAST Data – Cluster Resource Deployment for Demo/POC
#
# Purpose:
# - Provision a full VAST Data POC/Demo cluster in Google Cloud.
# - Create DNS, VIP pools, tenants, users/groups, policies, and views dynamically.
#
# Key Resources:
# 1. vastdata_dns           → DNS service for cluster VIP resolution.
# 2. vastdata_vip_pool      → Protocols (NFS/S3) and Replication VIP pools.
# 3. vastdata_tenant        → Tenant objects with client IP ranges.
# 4. vastdata_group/user    → POSIX groups and users for authentication.
# 5. vastdata_view_policy   → NFS and S3 access policies referencing VIP pools.
# 6. vastdata_view          → NFS views (dynamic by node count) and S3 views (map-driven).
#
# Features:
# - Dependencies enforced (`depends_on`) to ensure proper creation order.
# - Pools, policies, and views are fully driven from `.tfvars` and `locals.tf`.
# - Supports multi-protocol (NFS + S3) access and multiple tenants/users.
#
# Usage Notes:
# - Requires `provider "vastdata"` configuration elsewhere (e.g., provider.tf).
# - Ensure `.tfvars` contains all required VIP pools and user/group maps.
# - Apply in stages: `terraform init` → `terraform plan` → `terraform apply`.
###===================================================================================###

###===================================================================================###
# DNS
###===================================================================================###
resource "vastdata_dns" "protocol_dns" {
  provider      = vastdata.GCPCluster
  name          = var.dns_name
  vip           = var.dns_vip
  net_type      = var.port_type
  domain_suffix = var.dns_domain_suffix
  enabled       = var.dns_enabled
}

###===================================================================================###
# VIP Pools - Protocol and Replication
###===================================================================================###

resource "vastdata_vip_pool" "protocols" {
  provider = vastdata.GCPCluster

  for_each = local.protocols_pools

  name        = each.value.name
  subnet_cidr = each.value.subnet_cidr
  role        = each.value.role

  ip_ranges = [
    for r in each.value.ip_ranges : r
  ]

  gw_ip       = try(each.value.gateway, null)
  domain_name = try(each.value.dns_name, null)

  depends_on = [vastdata_dns.protocol_dns]
}

resource "vastdata_vip_pool" "replication" {
  provider = vastdata.GCPCluster

  for_each = local.replication_pools

  name        = each.value.name
  subnet_cidr = each.value.subnet_cidr
  role        = each.value.role

  ip_ranges = [
    for r in each.value.ip_ranges : r
  ]

  gw_ip       = try(each.value.gateway, null)
  domain_name = try(each.value.dns_name, null)

  depends_on = [vastdata_dns.protocol_dns]
}

###===================================================================================###
# NFS View Policy
###===================================================================================###
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

  vippool_permissions = [
    {
      vippool_id          = vastdata_vip_pool.protocols[local.sharespool_key].id
      vippool_permissions = var.vippool_permissions
    }
  ]
}

###===================================================================================###
# NFS Views
###===================================================================================###
resource "vastdata_view" "nfs_views" {
  provider  = vastdata.GCPCluster
  count     = local.effective_num_views

  policy_id = vastdata_view_policy.nfs_basic_policy.id
  path      = "/${var.path_name}${count.index + 1}"
  protocols = var.protocols
  create_dir = var.create_dir
}

###===================================================================================###
# S3 View Policy
###===================================================================================###
resource "vastdata_view_policy" "s3_basic_policy" {
  provider = vastdata.GCPCluster
  name     = var.s3_basic_policy_name
  flavor   = var.s3_flavor

  s3_special_chars_support = var.s3_special_chars_support
  use_auth_provider        = var.use_auth_provider
  auth_source              = var.auth_source
  access_flavor            = var.access_flavor

  nfs_no_squash  = var.nfs_no_squash
  nfs_read_write = var.nfs_read_write
  nfs_read_only  = var.nfs_read_only
  smb_read_write = var.smb_read_write
  smb_read_only  = var.smb_read_only

  vippool_permissions = [
    {
      vippool_id          = vastdata_vip_pool.protocols[local.s3pool_key].id
      vippool_permissions = var.vippool_permissions
    }
  ]
}

###===================================================================================###
# S3 Views
###===================================================================================###
resource "vastdata_view" "s3_views" {
  for_each = local.s3_views

  provider   = vastdata.GCPCluster
  policy_id  = each.value.policy_id
  name       = each.value.name
  bucket     = each.value.bucket
  path       = each.value.path
  protocols  = each.value.protocols
  create_dir = each.value.create_dir
  bucket_owner = each.value.bucket_owner
  allow_s3_anonymous_access = lookup(each.value, "allow_s3_anonymous_access", false)

  depends_on = [vastdata_user.users]
}

###===================================================================================###
# S3 Allow-All Policy
###===================================================================================###
resource "vastdata_s3_policy" "s3policy_user_allowall" {
  provider = vastdata.GCPCluster
  name     = var.s3_allowall_policy_name
  policy   = file("${path.module}/${var.s3_allowall_policy_file}")
  enabled  = true
}

###===================================================================================###
# Active Directory – Original Working Setup
###===================================================================================###
resource "vastdata_active_directory" "gcp_ad1" {
  provider             = vastdata.GCPCluster
  machine_account_name = var.ou_name
  organizational_unit  = var.ad_ou
  use_auto_discovery   = var.use_ad
  binddn               = var.bind_dn
  bindpw               = var.bindpw
  use_ldaps            = var.ldap
  domain_name          = var.ad_domain
  method               = var.method
  query_groups_mode    = var.query_mode
  use_tls              = var.use_tls
}
