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
#   - Resources use the 'vastdata.GCPCluster_1' provider.
######################################################################

###=============================================================================
###--- VIEW POLICIES
###=============================================================================

# NFS Basic Policy
resource "vastdata_view_policy" "voc_standard_nfs" {
  provider = vastdata.GCPCluster_1
  for_each = var.nfs_policies

  # Attributes that are likely defined and NOT causing the error:
  name             = each.value.name           #  <-- ERROR: Missing
  flavor           = each.value.flavor
  nfs_read_write   = each.value.nfs_read_write
  nfs_read_only    = each.value.nfs_read_only
  nfs_no_squash    = each.value.nfs_no_squash
  smb_read_write   = each.value.smb_read_write
  smb_read_only    = each.value.smb_read_only

  # --- Attributes you should remove or add to var.nfs_policies ---
  access_flavor                    = each.value.access_flavor    
  allowed_characters               = each.value.allowed_characters
  nfs_root_squash                  = each.value.nfs_root_squash  
  nfs_posix_acl                    = each.value.nfs_posix_acl   
  gid_inheritance                  = each.value.gid_inheritance 
  enable_access_to_snapshot_dir_in_subdirs = each.value.enable_access_to_snapshot_dir_in_subdirs 
}

### S3 Basic Policy
resource "vastdata_view_policy" "voc_standard_s3" {
  provider = vastdata.GCPCluster_1
  for_each = var.s3_policies

  # Attributes that are likely defined and NOT causing the error:
  name            = each.value.name    #                         <-- ERROR: Missing
  flavor          = each.value.flavor
  s3_read_write   = each.value.s3_read_write
  s3_read_only    = each.value.s3_read_only
  #special_chars   = each.value.special_chars # Note: The .tfvars uses 'special_chars', but the error lists 's3_special_chars_support'

  # --- Attributes you should remove or add to var.s3_policies ---
  access_flavor                  = each.value.access_flavor                    
  allowed_characters             = each.value.allowed_characters               
  s3_flavor_allow_free_listing   = each.value.s3_flavor_allow_free_listing    
  s3_flavor_detect_full_pathname = each.value.s3_flavor_detect_full_pathname 
  s3_special_chars_support       = each.value.s3_special_chars_support      
  gid_inheritance                = each.value.gid_inheritance              
  enable_access_to_snapshot_dir_in_subdirs = each.value.enable_access_to_snapshot_dir_in_subdirs
}

#=============================================================================
# NFS VIEWS
#=============================================================================
resource "vastdata_view" "file_views" {
  # Change: Reference the variable directly
  for_each = var.file_views_config 

  provider   = vastdata.GCPCluster_1
  name       = each.value.name
  path       = each.value.path
  protocols  = each.value.protocols
  create_dir = each.value.create_dir
  
  # The policy_id must reference the policy resource using the key from the view config
  policy_id  = vastdata_view_policy.voc_standard_nfs[each.value.policy].id
}

#=============================================================================
# S3 VIEWS
#=============================================================================
resource "vastdata_view" "s3_views" {
  # Change: Reference the variable directly
  for_each = var.s3_views_config

  provider                      = vastdata.GCPCluster_1
  name                          = each.value.name
  bucket                        = each.value.bucket
  path                          = each.value.path
  protocols                     = each.value.protocols
  create_dir                    = each.value.create_dir
  bucket_owner                  = each.value.bucket_owner
  allow_s3_anonymous_access     = lookup(each.value, "allow_s3_anonymous_access", false)
  
  # The policy_id must reference the policy resource using the key from the view config
  policy_id                     = vastdata_view_policy.voc_standard_s3[each.value.policy].id
  
  depends_on = [vastdata_user.users]
}


###===================================================================================###
### Get existing resources
###===================================================================================###

/*
# Default view ppolicy
data "vastdata_view_policy" "vastdb_view_policy_default" {
  name = "default"
}
*/
/* 
resource "vastdata_view_policy" "default" {
  provider   = vastdata.GCPCluster_1
  name = "default"
}

 */
