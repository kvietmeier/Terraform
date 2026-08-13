## VAST Data Terraform Template: Views, Policies & Block Storage


### Usage

You will need to set the cluster VMS information as environment variables.

Linux:

```bash
export TF_VAR_vast_host="192.168.1.100"
export TF_VAR_vast_username="admin"
export TF_VAR_vast_password="YourActualVMSPasswordHere"
```

Windows:

```powershell
$env:TF_VAR_vast_host = "192.168.1.100"
$env:TF_VAR_vast_username = "admin"
$env:TF_VAR_vast_password = "YourActualVMSPasswordHere"
```

---

### Complete View Reference

```hcl
# full_template.tfvars
# ==============================================================================
# VAST DATA VIEW POLICY - EXHAUSTIVE PARAMETER REFERENCE
# ==============================================================================
# Use this file as a complete reference for all available options.

view_policies_config = {
  "exhaustive_reference_policy" = {
    
    # --------------------------------------------------------------------------
    # 1. Core Policy Identity & Scope
    # --------------------------------------------------------------------------
    name          = "exhaustive_reference_policy"
    cluster       = "voc1-cluster01f"
    tenant_name   = "default"
    flavor        = "NFS"   # Options: "NFS", "SMB", "S3", "S3_NATIVE", "MIXED"
    access_flavor = "ALL"   # Options: "ALL", "READ_ONLY", etc.
    auth_source   = "RPC"   # Options: "RPC", "AD", "LDAP", "RPC_AND_PROVIDERS"

    # --------------------------------------------------------------------------
    # 2. General & Path Behavior
    # --------------------------------------------------------------------------
    allowed_characters       = "LCD"   # Options: "LCD" (Low Char Domain), "NPL", etc.
    path_length              = "LCD"   # Options: "LCD", "NPL", etc.
    gid_inheritance          = "LINUX" # Options: "LINUX", "PARENT"
    inherit_parent_mode_bits = false   # Inherit mode bits on directory creation

    # --------------------------------------------------------------------------
    # 3. Snapshot Directory Visibility Controls
    # --------------------------------------------------------------------------
    enable_access_to_snapshot_dir_in_subdirs = true  # Allow cd .snapshot in subdirs
    enable_listing_of_snapshot_dir           = false # Show .snapshot in 'ls -a'
    enable_snapshot_lookup                   = true  # Allow explicit lookup of .snapshot
    enable_visibility_of_snapshot_dir        = false # Global visibility toggle

    # --------------------------------------------------------------------------
    # 4. NFS Protocol Settings
    # --------------------------------------------------------------------------
    nfs_minimal_protection_level = "SYSTEM" # Options: "SYSTEM", "KRB5", "KRB5I", "KRB5P"
    nfs_case_insensitive         = false    # Treat NFS filenames as case-insensitive
    nfs_enforce_tls              = false    # Require TLS for NFS connections
    nfs_enforce_tls_relaxed      = false    # Allow fallback if TLS fails
    nfs_posix_acl                = false    # Enable POSIX ACL support
    nfs_return_open_permissions  = false    # Return open perms on getattr
    nfs_read_write               = ["*"]    # Hosts with Read/Write access
    nfs_read_only                = []       # Hosts with Read-Only access
    nfs_root_squash              = ["*"]    # Map root (uid 0) to anonymous ID
    nfs_all_squash               = []       # Map all users to anonymous ID
    nfs_no_squash                = []       # Exclude hosts from root squash

    # --------------------------------------------------------------------------
    # 5. S3 Protocol Settings
    # --------------------------------------------------------------------------
    is_s3_default_policy           = false # Set as default S3 bucket policy
    s3_flavor_allow_free_listing   = false # Allow free listing optimization
    s3_flavor_detect_full_pathname = false # Automatically detect full pathnames
    s3_special_chars_support       = true  # Support special characters in S3 keys
    s3_read_write                  = ["*"] # S3 users/hosts with R/W access
    s3_read_only                   = []    # S3 users/hosts with Read-Only access

    # --------------------------------------------------------------------------
    # 6. SMB Protocol Settings
    # --------------------------------------------------------------------------
    apple_sid            = false # Support Apple SID extensions
    disable_handle_lease = false # Disable SMB handle leases
    disable_read_lease   = false # Disable SMB read leases
    disable_write_lease  = false # Disable SMB write leases
    smb_directory_mode   = 755   # Default POSIX permissions for created SMB dirs
    smb_file_mode        = 644   # Default POSIX permissions for created SMB files
    smb_is_ca            = false # Enable Continuously Available (CA) shares
    smb_read_write       = ["*"] # Active Directory users/groups with R/W
    smb_read_only        = []    # Active Directory users/groups with Read-Only

    # --------------------------------------------------------------------------
    # 7. Global Access Flags & Runtime Bindings
    # --------------------------------------------------------------------------
    expose_id_in_fsid = false # Expose view ID inside file system ID
    use_32bit_fileid  = false # Limit file IDs to 32-bit (for legacy apps)
    use_auth_provider = false # Require Active Directory / LDAP authentication
    read_write        = ["*"] # Global Read-Write client list
    read_only         = []    # Global Read-Only client list
    vip_pools         = null  # Restrict to specific VIP Pool names
    serves_tenant     = null  # Restrict to specific tenant ID

    # --------------------------------------------------------------------------
    # 8. Protocol Audit Controls
    # --------------------------------------------------------------------------
    protocols_audit = {
      create_delete_files_dirs_objects = false # Audit file/object creation and deletion
      log_full_path                    = false # Log full file paths in audit trail
      log_username                     = false # Log authenticated usernames
      modify_data_md                   = false # Audit metadata modifications
      read_data                        = false # Audit data read operations
    }
  }
}
```

---