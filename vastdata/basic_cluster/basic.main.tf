######################################################################
# main.tf
# This Terraform file defines:
#   1. View policies for NFS and S3 protocols
#   2. NFS file system views
#   3. S3 bucket views
#
# Notes:
#   - All policy names, flavors, and protocols are now configurable via variables.
#   - NFS views automatically use the NFS basic policy.
#   - S3 views reference a policy defined per view.
#   - SMB or AD-integrated views can be added as needed.
#   - Resources use the 'vastdata.GCPCluster' provider.
######################################################################
###=============================================================================
###--- VIEW POLICIES
###=============================================================================

# NFS Basic Policy
resource "vastdata_view_policy" "nfs_basic_policy" {
  provider       = vastdata.GCPCluster
  name           = var.nfs_basic_policy_name
  flavor         = var.nfs_basic_policy_flavor
  nfs_no_squash  = var.nfs_no_squash
  nfs_read_write = var.nfs_read_write
}

# S3 Basic Policy
resource "vastdata_view_policy" "s3_basic_policy" {
  provider = vastdata.GCPCluster
  name     = var.s3_basic_policy_name
  flavor   = var.s3_basic_policy_flavor
}

###=============================================================================
###--- NFS VIEWS
###=============================================================================
# Creates NFS data path mappings directly from var.file_views_config map
resource "vastdata_view" "file_views" {
  provider = vastdata.GCPCluster
  for_each = var.file_views_config

  name       = each.value.name
  path       = each.value.path
  alias      = each.value.path
  protocols  = each.value.protocols
  policy_id  = vastdata_view_policy.nfs_basic_policy.id
  create_dir = each.value.create_dir
}

###=============================================================================
###--- S3 VIEWS
###=============================================================================
# Creates S3 and Database views straight from your var.s3_views_config map
resource "vastdata_view" "s3_views" {
  provider = vastdata.GCPCluster
  for_each = var.s3_views_config

  name       = each.value.name
  path       = each.value.path
  bucket     = each.value.bucket
  protocols  = each.value.protocols
  create_dir = each.value.create_dir
  
  # References the centralized global S3 policy id dynamically
  policy_id  = vastdata_view_policy.s3_basic_policy.id

  # Maps bucket owners to the POSIX data-plane identities
  bucket_owner              = each.value.bucket_owner
  allow_s3_anonymous_access = lookup(each.value, "allow_s3_anonymous_access", false)

  # Explicitly wait for users and groups to exist before creating storage targets
  depends_on = [vastdata_user.users]
}

###===================================================================================###
# DNS Configuration
###===================================================================================###
resource "vastdata_dns" "protocol_dns" {
  provider      = vastdata.GCPCluster
  name          = var.dns_name
  vip           = var.dns_vip
  net_type      = var.port_type
  domain_suffix = var.dns_domain_suffix
  enabled       = var.dns_enabled
}
