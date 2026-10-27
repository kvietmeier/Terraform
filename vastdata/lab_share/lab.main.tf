###===================================================================================###
#
#  File:        lab.main.tf
#  Author:      Karl Vietmeier
#
#  Description:
#  Terraform equivalent of vastops/create_lab_share.py:
#    lab_policy + /lab_share view (default NFSv3 + S3), optional SMB,
#    and local user "lab" as S3 bucket_owner.
#
#  WARNING: Intentionally wide open (RW "*", no squash, loose SMB modes).
#  Lab / throwaway testing only — not for customer production.
#
###===================================================================================###

locals {
  want_nfs = contains(var.protocols, "NFS")
  want_smb = contains(var.protocols, "SMB")
  want_s3  = contains(var.protocols, "S3")
}

# -------------------------------------------------------------------------
# Lookups
# -------------------------------------------------------------------------

data "vastdata_tenant" "selected" {
  name = var.tenant_name
}

# Cloud VOC Stage 1 already created this pool — bind policy to it (do not create).
data "vastdata_vip_pool" "protocols" {
  name = var.vip_pool_existing
}

# -------------------------------------------------------------------------
# Local lab user (S3 bucket_owner). VMS admin is not a tenant data user.
# -------------------------------------------------------------------------

resource "vastdata_user" "lab" {
  count = local.want_s3 ? 1 : 0

  name                = var.lab_user_name
  uid                 = var.lab_user_uid
  leading_gid         = var.lab_user_uid
  gids                = [var.lab_user_uid]
  local_provider_id   = var.local_provider_id
  allow_create_bucket = true
  allow_delete_bucket = true
  s3_superuser        = true
}

# -------------------------------------------------------------------------
# View policy — lab-open multiprotocol
# -------------------------------------------------------------------------

resource "vastdata_view_policy" "lab" {
  name                                     = var.policy_name
  flavor                                   = var.policy_flavor
  auth_source                              = var.auth_source
  allowed_characters                       = var.allowed_characters
  path_length                              = var.path_length
  gid_inheritance                          = var.gid_inheritance
  enable_access_to_snapshot_dir_in_subdirs = var.enable_access_to_snapshot_dir_in_subdirs

  nfs_read_write  = local.want_nfs ? var.nfs_read_write : null
  nfs_no_squash   = local.want_nfs ? var.nfs_no_squash : null
  nfs_root_squash = local.want_nfs ? var.nfs_root_squash : null

  smb_read_write     = local.want_smb ? var.smb_read_write : null
  smb_file_mode      = local.want_smb ? var.smb_file_mode : null
  smb_directory_mode = local.want_smb ? var.smb_directory_mode : null

  s3_read_write = local.want_s3 ? var.s3_read_write : null

  # Provider 3.2.2+: map vip_pool_id -> permission (existing protocolsPool)
  permission_per_vip_pool = {
    tostring(data.vastdata_vip_pool.protocols.id) = var.vippool_permissions
  }
}

# -------------------------------------------------------------------------
# View — /lab_share (share + bucket when those protocols are enabled)
# -------------------------------------------------------------------------

resource "vastdata_view" "lab_share" {
  name       = var.view_name
  path       = var.view_path
  protocols  = var.protocols
  create_dir = var.create_dir
  policy_id  = vastdata_view_policy.lab.id
  tenant_id  = data.vastdata_tenant.selected.id

  share        = local.want_smb ? var.share_name : null
  bucket       = local.want_s3 ? var.bucket_name : null
  bucket_owner = local.want_s3 ? var.lab_user_name : null

  depends_on = [vastdata_user.lab]
}
