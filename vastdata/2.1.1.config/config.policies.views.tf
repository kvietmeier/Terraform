######################################################################
# VAST Data Cluster: View Policies and Views
#
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
# - Flavor and protocols are configurable via variables:
#     var.nfs_basic_policy_flavor
#     var.nfs_basic_policy_protocols
resource "vastdata_view_policy" "nfs_basic_policy" {
  provider  = vastdata.GCPCluster
  name      = var.nfs_basic_policy_name
  flavor    = var.nfs_basic_policy_flavor
  protocols = var.nfs_basic_policy_protocols
}

# S3 Basic Policy
# - Flavor and protocols are configurable via variables:
#     var.s3_basic_policy_flavor
#     var.s3_basic_policy_protocols
resource "vastdata_view_policy" "s3_basic_policy" {
  provider  = vastdata.GCPCluster
  name      = var.s3_basic_policy_name
  flavor    = var.s3_basic_policy_flavor
  protocols = var.s3_basic_policy_protocols
}

#=============================================================================
# NFS VIEWS
#=============================================================================
# Creates NFS views from var.file_views_config
# - Each view is assigned the NFS basic policy
# - The 'create_dir' flag creates the path if parent exists
resource "vastdata_view" "file_views" {
  provider = vastdata.GCPCluster
  for_each = var.file_views_config

  name       = each.value.name
  path       = each.value.path
  protocols  = each.value.protocols
  policy_id  = vastdata_view_policy.nfs_basic_policy.id
  create_dir = each.value.create_dir
}

#=============================================================================
# S3 VIEWS
#=============================================================================
# Creates S3 views from local.s3_views
# - Each view references a specific policy via each.value.policy_id
# - Supports bucket owner and optional anonymous access
# - Depends on vastdata_user.users for proper permissions
resource "vastdata_view" "s3_views" {
  provider   = vastdata.GCPCluster
  for_each   = local.s3_views

  name       = each.value.name
  path       = each.value.path
  bucket     = each.value.bucket
  protocols  = each.value.protocols
  create_dir = each.value.create_dir
  policy_id  = each.value.policy_id

  bucket_owner              = each.value.bucket_owner
  allow_s3_anonymous_access = lookup(each.value, "allow_s3_anonymous_access", false)

  depends_on = [vastdata_user.users]
}


# The below is an alternative S3 view resource definition that uses var.s3_views_config directly.
# It is functionally equivalent to the active s3_views resource above.

/* resource "vastdata_view" "s3_views" {
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
 */