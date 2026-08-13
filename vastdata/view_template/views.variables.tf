# variables.tf

# ------------------------------------------------------------------------------
# VAST Provider Authentication & Connection Variables
# ------------------------------------------------------------------------------
variable "vast_host" {
  description = "Management IP or hostname of the VAST cluster VMS."
  type        = string
}

variable "vast_port" {
  description = "Port number for the VAST VMS API (default: 443)."
  type        = number
  default     = 443
}

variable "vast_username" {
  description = "Username for VAST VMS API authentication."
  type        = string
}

variable "vast_password" {
  description = "Password for VAST VMS API. Supplied via TF_VAR_vast_password environment variable."
  type        = string
  sensitive   = true # Prevents password from displaying in CLI logs
}

variable "vast_skip_ssl_verify" {
  description = "Disable SSL certificate validation for VMS connection."
  type        = bool
  default     = true
}



# ------------------------------------------------------------------------------
# View Policy Schema
# ------------------------------------------------------------------------------
variable "view_policies_config" {
  description = "Map of user-configurable parameters for VAST Data View Policies."
  type = map(object({
    name          = string
    cluster       = string
    tenant_name   = string
    flavor        = string
    access_flavor = string
    auth_source   = string

    allowed_characters       = string
    path_length              = string
    gid_inheritance          = string
    inherit_parent_mode_bits = bool

    enable_access_to_snapshot_dir_in_subdirs = bool
    enable_listing_of_snapshot_dir          = bool
    enable_snapshot_lookup                  = bool
    enable_visibility_of_snapshot_dir       = bool

    nfs_minimal_protection_level = string
    nfs_case_insensitive         = bool
    nfs_enforce_tls              = bool
    nfs_enforce_tls_relaxed      = bool
    nfs_posix_acl                = bool
    nfs_return_open_permissions  = bool
    nfs_read_write               = list(string)
    nfs_root_squash              = list(string)
    nfs_all_squash               = list(string)
    nfs_no_squash                = list(string)
    nfs_read_only                = list(string)

    is_s3_default_policy           = bool
    s3_flavor_allow_free_listing   = bool
    s3_flavor_detect_full_pathname = bool
    s3_special_chars_support       = bool
    s3_read_write                  = list(string)
    s3_read_only                   = list(string)

    apple_sid            = bool
    disable_handle_lease = bool
    disable_read_lease   = bool
    disable_write_lease  = bool
    smb_directory_mode   = number
    smb_file_mode        = number
    smb_is_ca            = bool
    smb_read_write       = list(string)
    smb_read_only        = list(string)

    expose_id_in_fsid = bool
    use_32bit_fileid  = bool
    use_auth_provider = bool
    read_write        = list(string)
    read_only         = list(string)

    vip_pools     = optional(list(string))
    serves_tenant = optional(string)

    protocols_audit = object({
      create_delete_files_dirs_objects = bool
      log_full_path                    = bool
      log_username                     = bool
      modify_data_md                   = bool
      read_data                        = bool
    })
  }))
}

# ------------------------------------------------------------------------------
# File Views Schema (NFS / SMB / S3)
# ------------------------------------------------------------------------------
variable "file_views_config" {
  description = "Map of user-configurable VAST Data Views."
  type = map(object({
    name        = string
    path        = string
    protocols   = list(string)
    create_dir  = bool
    policy_key  = string
    tenant_name = optional(string)
    vip_pools   = optional(list(string))
  }))
  default = {}
}

# ------------------------------------------------------------------------------
# Block Storage Schemas (Block Host & Host Mapping)
# ------------------------------------------------------------------------------
variable "block_hosts_config" {
  description = "Map of user-configurable VAST Data Block Hosts."
  type = map(object({
    name        = string
    tenant_name = optional(string)
    os_type     = optional(string)
    initiators  = list(string) # WWPNs, IQNs, or NQNs
  }))
  default = {}
}

variable "block_host_mappings_config" {
  description = "Map of user-configurable VAST Data Block Host Mappings."
  type = map(object({
    host_key  = string # Matches key defined in var.block_hosts_config
    volume_id = number # VAST Block Volume ID to map
    lun       = optional(number)
  }))
  default = {}
}