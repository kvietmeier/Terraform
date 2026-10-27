# terraform.tfvars
# Provider Connection Settings
vast_port            = 443
vast_skip_ssl_verify = true



###----------------------------- View Policies -------------------------------###
#   The type of policy is determined by the choice of settings for the following attributes:
#     flavor: NFS, SMB, S3
#     access_flavor: ALL, READ_ONLY, READ_WRITE
#     auth_source: RPC, RPC_AND_PROVIDERS, PROVIDERS
#     use_auth_provider: true, false
#   

###--- Lab View Policies
lab_view_policies_config = {

  # Standard Lab NFS Policy
  "lab_nfs_policy" = {
    flavor             = "NFS"
    auth_source        = "RPC"
    allowed_characters = "LCD"
    path_length        = "LCD"
    nfs_read_write     = ["*"]
    nfs_read_only      = []
    nfs_root_squash    = ["*"]
    nfs_no_squash      = []
    gid_inheritance    = "LINUX"
  },

  # Standard Lab SMB Policy
  "lab_smb_policy" = {
    flavor             = "SMB"
    auth_source        = "RPC_AND_PROVIDERS"
    allowed_characters = "LCD"
    path_length        = "LCD"
    smb_read_write     = ["*"]
    smb_read_only      = []
    smb_file_mode      = 644
    smb_directory_mode = 755
    use_auth_provider  = true
  },

  # Standard Lab S3 Policy
  "lab_s3_policy" = {
    flavor                         = "S3_NATIVE"
    auth_source                    = "RPC"
    allowed_characters             = "NPL"
    path_length                    = "NPL"
    s3_read_write                  = ["*"]
    s3_read_only                   = []
    s3_special_chars_support       = true
    s3_flavor_allow_free_listing   = false
    s3_flavor_detect_full_pathname = false
  }

}

###----------------------------- File Views -------------------------------###
file_views_config = {
  "nfs_export_view" = {
    name        = "nfs_data_export"
    path        = "/exports/nfs_data"
    protocols   = ["NFS"]
    create_dir  = true
    policy_key  = "lab_nfs_policy"
    tenant_name = "default"
    vip_pools   = null
  },
  "s3_bucket_view" = {
    name        = "s3_app_bucket"
    path        = "/buckets/app_data"
    protocols   = ["S3"]
    create_dir  = true
    policy_key  = "lab_s3_policy"
    tenant_name = "default"
    vip_pools   = null
  },
  "SMB_share_view" = {
    name        = "smb_shared_data"
    path        = "/shares/smb_data"
    protocols   = ["SMB"]
    create_dir  = true
    policy_key  = "lab_smb_policy"
    tenant_name = "default"
    vip_pools   = null
  }
}


###-------------------------------- Block Hosts -------------------------------###
block_hosts_config = {
  "db_server_01" = {
    name        = "db-server-01"
    tenant_name = "default"
    os_type     = "LINUX"
    initiators  = ["iqn.1994-05.com.redhat:db-server-01"]
  },
  "db_server_02" = {
    name        = "db-server-02"
    tenant_name = "default"
    os_type     = "LINUX"
    initiators  = ["iqn.1994-05.com.redhat:db-server-02"]
  }
}

# Block Host Mappings
block_host_mappings_config = {
  "db_host_mapping_vol1" = {
    host_key  = "db_server_01"
    volume_id = 101
    lun       = 1
  },
  "db_host_mapping_vol2" = {
    host_key  = "db_server_02"
    volume_id = 102
    lun       = 2
  }
}