# terraform.tfvars

# View Policies
view_policies_config = {
  "nfs_standard_policy" = {
    name                                     = "nfs_standard_policy"
    cluster                                  = "voc1-cluster01f"
    tenant_name                              = "default"
    flavor                                   = "NFS"
    access_flavor                            = "ALL"
    auth_source                              = "RPC"
    allowed_characters                       = "LCD"
    path_length                              = "LCD"
    gid_inheritance                          = "LINUX"
    inherit_parent_mode_bits                 = false
    enable_access_to_snapshot_dir_in_subdirs = true
    enable_listing_of_snapshot_dir           = false
    enable_snapshot_lookup                   = true
    enable_visibility_of_snapshot_dir        = false
    nfs_minimal_protection_level             = "SYSTEM"
    nfs_case_insensitive                     = false
    nfs_enforce_tls                          = false
    nfs_enforce_tls_relaxed                  = false
    nfs_posix_acl                            = false
    nfs_return_open_permissions              = false
    nfs_read_write                           = ["*"]
    nfs_root_squash                          = ["*"]
    nfs_all_squash                           = []
    nfs_no_squash                            = []
    nfs_read_only                            = []
    is_s3_default_policy                     = false
    s3_flavor_allow_free_listing             = false
    s3_flavor_detect_full_pathname           = false
    s3_special_chars_support                 = true
    s3_read_write                            = []
    s3_read_only                             = []
    apple_sid                                = false
    disable_handle_lease                     = false
    disable_read_lease                       = false
    disable_write_lease                      = false
    smb_directory_mode                       = 755
    smb_file_mode                            = 644
    smb_is_ca                                = false
    smb_read_write                           = []
    smb_read_only                            = []
    expose_id_in_fsid                        = false
    use_32bit_fileid                         = false
    use_auth_provider                        = false
    read_write                               = ["*"]
    read_only                                = []
    vip_pools                                = null
    serves_tenant                            = null
    protocols_audit = {
      create_delete_files_dirs_objects = false
      log_full_path                    = false
      log_username                     = false
      modify_data_md                   = false
      read_data                        = false
    }
  },
  "s3_standard_policy" = {
    name                                     = "s3_standard_policy"
    cluster                                  = "voc1-cluster01f"
    tenant_name                              = "default"
    flavor                                   = "S3"
    access_flavor                            = "ALL"
    auth_source                              = "RPC"
    allowed_characters                       = "LCD"
    path_length                              = "LCD"
    gid_inheritance                          = "LINUX"
    inherit_parent_mode_bits                 = false
    enable_access_to_snapshot_dir_in_subdirs = false
    enable_listing_of_snapshot_dir           = false
    enable_snapshot_lookup                   = false
    enable_visibility_of_snapshot_dir        = false
    nfs_minimal_protection_level             = "SYSTEM"
    nfs_case_insensitive                     = false
    nfs_enforce_tls                          = false
    nfs_enforce_tls_relaxed                  = false
    nfs_posix_acl                            = false
    nfs_return_open_permissions              = false
    nfs_read_write                           = []
    nfs_root_squash                          = []
    nfs_all_squash                           = []
    nfs_no_squash                            = []
    nfs_read_only                            = []
    is_s3_default_policy                     = true
    s3_flavor_allow_free_listing             = true
    s3_flavor_detect_full_pathname           = true
    s3_special_chars_support                 = true
    s3_read_write                            = ["*"]
    s3_read_only                             = []
    apple_sid                                = false
    disable_handle_lease                     = false
    disable_read_lease                       = false
    disable_write_lease                      = false
    smb_directory_mode                       = 755
    smb_file_mode                            = 644
    smb_is_ca                                = false
    smb_read_write                           = []
    smb_read_only                            = []
    expose_id_in_fsid                        = false
    use_32bit_fileid                         = false
    use_auth_provider                        = false
    read_write                               = ["*"]
    read_only                                = []
    vip_pools                                = null
    serves_tenant                            = null
    protocols_audit = {
      create_delete_files_dirs_objects = false
      log_full_path                    = false
      log_username                     = false
      modify_data_md                   = false
      read_data                        = false
    }
  }
}

# File Views
file_views_config = {
  "nfs_export_view" = {
    name        = "nfs_data_export"
    path        = "/exports/nfs_data"
    protocols   = ["NFS"]
    create_dir  = true
    policy_key  = "nfs_standard_policy"
    tenant_name = "default"
    vip_pools   = null
  },
  "s3_bucket_view" = {
    name        = "s3_app_bucket"
    path        = "/buckets/app_data"
    protocols   = ["S3"]
    create_dir  = true
    policy_key  = "s3_standard_policy"
    tenant_name = "default"
    vip_pools   = null
  }
}

# Block Hosts
block_hosts_config = {
  "db_server_01" = {
    name        = "db-server-01"
    tenant_name = "default"
    os_type     = "LINUX"
    initiators  = ["iqn.1994-05.com.redhat:db-server-01"]
  }
}

# Block Host Mappings
block_host_mappings_config = {
  "db_host_mapping_vol1" = {
    host_key  = "db_server_01"
    volume_id = 101
    lun       = 1
  }
}