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
######################################################################


###=============================================================================
###--- Provider
###=============================================================================

terraform {
  required_providers {
    vastdata = {
      source  = "vast-data/vastdata"
      version = ">= 3.2.2"
    }
  }
}

provider "vastdata" {
  username        = var.vast_username
  password        = var.vast_password
  host            = var.vast_host
  port            = var.vast_port
  skip_ssl_verify = var.vast_skip_ssl_verify
  #alias           = "cluster"
}

# ------------------------------------------------------------------------------
# 1. Policy Resource Block
# ------------------------------------------------------------------------------
resource "vastdata_view_policy" "this" {
  for_each = var.view_policies_config

  name          = each.value.name
  cluster       = each.value.cluster
  tenant_name   = each.value.tenant_name
  flavor        = each.value.flavor
  access_flavor = each.value.access_flavor
  auth_source   = each.value.auth_source

  allowed_characters       = each.value.allowed_characters
  path_length              = each.value.path_length
  gid_inheritance          = each.value.gid_inheritance
  inherit_parent_mode_bits = each.value.inherit_parent_mode_bits

  enable_access_to_snapshot_dir_in_subdirs = each.value.enable_access_to_snapshot_dir_in_subdirs
  enable_listing_of_snapshot_dir           = each.value.enable_listing_of_snapshot_dir
  enable_snapshot_lookup                   = each.value.enable_snapshot_lookup
  enable_visibility_of_snapshot_dir        = each.value.enable_visibility_of_snapshot_dir

  nfs_minimal_protection_level = each.value.nfs_minimal_protection_level
  nfs_case_insensitive         = each.value.nfs_case_insensitive
  nfs_enforce_tls              = each.value.nfs_enforce_tls
  nfs_enforce_tls_relaxed      = each.value.nfs_enforce_tls_relaxed
  nfs_posix_acl                = each.value.nfs_posix_acl
  nfs_return_open_permissions  = each.value.nfs_return_open_permissions
  nfs_read_write               = each.value.nfs_read_write
  nfs_root_squash              = each.value.nfs_root_squash
  nfs_all_squash               = each.value.nfs_all_squash
  nfs_no_squash                = each.value.nfs_no_squash
  nfs_read_only                = each.value.nfs_read_only

  is_s3_default_policy           = each.value.is_s3_default_policy
  s3_flavor_allow_free_listing   = each.value.s3_flavor_allow_free_listing
  s3_flavor_detect_full_pathname = each.value.s3_flavor_detect_full_pathname
  s3_special_chars_support       = each.value.s3_special_chars_support
  s3_read_write                  = each.value.s3_read_write
  s3_read_only                   = each.value.s3_read_only

  apple_sid            = each.value.apple_sid
  disable_handle_lease = each.value.disable_handle_lease
  disable_read_lease   = each.value.disable_read_lease
  disable_write_lease  = each.value.disable_write_lease
  smb_directory_mode   = each.value.smb_directory_mode
  smb_file_mode        = each.value.smb_file_mode
  smb_is_ca            = each.value.smb_is_ca
  smb_read_write       = each.value.smb_read_write
  smb_read_only        = each.value.smb_read_only

  expose_id_in_fsid = each.value.expose_id_in_fsid
  use_32bit_fileid  = each.value.use_32bit_fileid
  use_auth_provider = each.value.use_auth_provider
  read_write        = each.value.read_write
  read_only         = each.value.read_only

  vip_pools     = each.value.vip_pools
  serves_tenant = each.value.serves_tenant

  protocols_audit = each.value.protocols_audit
}

# ------------------------------------------------------------------------------
# 2. View Resource Block
# ------------------------------------------------------------------------------
resource "vastdata_view" "file_views" {
  for_each = var.file_views_config

  name        = each.value.name
  path        = each.value.path
  protocols   = each.value.protocols
  create_dir  = each.value.create_dir
  tenant_name = each.value.tenant_name
  vip_pools   = each.value.vip_pools

  policy_id = vastdata_view_policy.this[each.value.policy_key].id
}

# ------------------------------------------------------------------------------
# 3. Block Host Resource Block
# ------------------------------------------------------------------------------
resource "vastdata_block_host" "hosts" {
  for_each = var.block_hosts_config

  name        = each.value.name
  tenant_name = each.value.tenant_name
  os_type     = each.value.os_type
  initiators  = each.value.initiators
}

# ------------------------------------------------------------------------------
# 4. Block Host Mapping Resource Block
# ------------------------------------------------------------------------------
resource "vastdata_block_host_mapping" "mappings" {
  for_each = var.block_host_mappings_config

  host_id   = vastdata_block_host.hosts[each.value.host_key].id
  volume_id = each.value.volume_id
  lun       = each.value.lun
}