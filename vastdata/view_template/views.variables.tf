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
# view policy schema
#
# This schema defines the structure for VAST Data view policies. Administrators
# apply these policies to NFS, SMB, and S3 views to manage access controls,
# protocol settings, and audit logging.
#
#  Optional attributes leverage Terraform's optional() type modifier. If you omit 
#  an optional attribute from your terraform.tfvars file, Terraform automatically 
#  applies the factory default value specified in this schema. You can override 
#  any default by explicitly defining the attribute in your tfvars file.
# ------------------------------------------------------------------------------

variable "lab_view_policies_config" {
  description = "Streamlined map for rapid testing and benchmarking VAST View Policies."
  type = map(object({
    # Core Identification
    name        = optional(string)
    cluster     = optional(string, "voc1-cluster01f")
    tenant_name = optional(string, "default")

    # Required Policy Attributes
    flavor             = string
    auth_source        = string
    allowed_characters = string
    path_length        = string

    # General Defaults
    access_flavor            = optional(string, "ALL")
    gid_inheritance          = optional(string, "LINUX")
    inherit_parent_mode_bits = optional(bool, false)

    # Snapshot Toggles
    enable_access_to_snapshot_dir_in_subdirs = optional(bool, true)
    enable_listing_of_snapshot_dir           = optional(bool, false)
    enable_snapshot_lookup                   = optional(bool, true)
    enable_visibility_of_snapshot_dir        = optional(bool, false)

    # NFS Attributes & Defaults
    nfs_minimal_protection_level = optional(string, "SYSTEM")
    nfs_case_insensitive         = optional(bool, false)
    nfs_enforce_tls              = optional(bool, false)
    nfs_enforce_tls_relaxed      = optional(bool, false)
    nfs_posix_acl                = optional(bool, false)
    nfs_return_open_permissions  = optional(bool, false)
    nfs_read_write               = optional(list(string), [])
    nfs_read_only                = optional(list(string), [])
    nfs_root_squash              = optional(list(string), [])
    nfs_all_squash               = optional(list(string), [])
    nfs_no_squash                = optional(list(string), [])

    # SMB Attributes & Defaults
    apple_sid            = optional(bool, false)
    disable_handle_lease = optional(bool, false)
    disable_read_lease   = optional(bool, false)
    disable_write_lease  = optional(bool, false)
    smb_directory_mode   = optional(number, 755)
    smb_file_mode        = optional(number, 644)
    smb_is_ca            = optional(bool, false)
    smb_read_write       = optional(list(string), [])
    smb_read_only        = optional(list(string), [])

    # S3 Attributes & Defaults
    is_s3_default_policy           = optional(bool, false)
    s3_flavor_allow_free_listing   = optional(bool, false)
    s3_flavor_detect_full_pathname = optional(bool, false)
    s3_special_chars_support       = optional(bool, false)
    s3_read_write                  = optional(list(string), [])
    s3_read_only                   = optional(list(string), [])

    # Global Access
    expose_id_in_fsid = optional(bool, false)
    use_32bit_fileid  = optional(bool, false)
    use_auth_provider = optional(bool, false)
    read_write        = optional(list(string), ["*"])
    read_only         = optional(list(string), [])

    vip_pools     = optional(list(string), null)
    serves_tenant = optional(string, null)

    # Audit Controls
    protocols_audit = optional(object({
      create_delete_files_dirs_objects = bool
      log_full_path                    = bool
      log_username                     = bool
      modify_data_md                   = bool
      read_data                        = bool
    }), {
      create_delete_files_dirs_objects = false
      log_full_path                    = false
      log_username                     = false
      modify_data_md                   = false
      read_data                        = false
    })
  }))
  default = {}
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