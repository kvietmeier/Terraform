###===================================================================================###
#
#  File:        lab.variables.tf
#  Author:      Karl Vietmeier
#
#  Description:
#  Inputs for lab_share — wide-open multiprotocol dump share for lab testing.
#  Defaults match vastops/create_lab_share.py (NFSv3 + S3, policy lab_policy).
#
###===================================================================================###

# -------------------------------------------------------------------------
# Lookups / identity
# -------------------------------------------------------------------------

variable "tenant_name" {
  description = "Existing tenant name (lookup; view is pinned via tenant_id)"
  type        = string
  default     = "default"
}

variable "local_provider_id" {
  description = "Local provider id for the lab S3 user (clusters usually ship id 1)"
  type        = number
  default     = 1
}

# -------------------------------------------------------------------------
# Protocols (VAST names: NFS = NFSv3, SMB, S3)
# -------------------------------------------------------------------------

variable "protocols" {
  description = "View protocols. Default nfs+s3 (no AD). Add SMB only when AD is ready."
  type        = list(string)
  default     = ["NFS", "S3"]

  validation {
    condition = alltrue([
      for p in var.protocols : contains(["NFS", "SMB", "S3"], p)
    ])
    error_message = "protocols must be a subset of [\"NFS\", \"SMB\", \"S3\"]."
  }
}

# -------------------------------------------------------------------------
# View / share / bucket names
# -------------------------------------------------------------------------

variable "view_path" {
  description = "Filesystem path for the lab view"
  type        = string
  default     = "/lab_share"
}

variable "view_name" {
  description = "Optional view name (defaults to share_name / path basename)"
  type        = string
  default     = "lab_share"
}

variable "share_name" {
  description = "SMB share name (used when SMB is in protocols)"
  type        = string
  default     = "lab_share"
}

variable "bucket_name" {
  description = "S3 bucket name (lowercase / hyphens; used when S3 is in protocols)"
  type        = string
  default     = "lab-share"
}

variable "create_dir" {
  description = "Create the view path directory if missing"
  type        = bool
  default     = true
}

# -------------------------------------------------------------------------
# View policy (lab-open defaults — not for production)
# -------------------------------------------------------------------------

variable "policy_name" {
  description = "View policy name"
  type        = string
  default     = "lab_policy"
}

variable "policy_flavor" {
  description = "Policy flavor (NFS for multiprotocol lab share)"
  type        = string
  default     = "NFS"
}

variable "auth_source" {
  type    = string
  default = "RPC_AND_PROVIDERS"
}

variable "allowed_characters" {
  type    = string
  default = "LCD"
}

variable "path_length" {
  type    = string
  default = "LCD"
}

variable "gid_inheritance" {
  type    = string
  default = "LINUX"
}

variable "enable_access_to_snapshot_dir_in_subdirs" {
  type    = bool
  default = true
}

variable "nfs_read_write" {
  type    = list(string)
  default = ["*"]
}

variable "nfs_no_squash" {
  type    = list(string)
  default = ["*"]
}

variable "nfs_root_squash" {
  type    = list(string)
  default = []
}

variable "smb_read_write" {
  type    = list(string)
  default = ["*"]
}

variable "smb_file_mode" {
  type    = number
  default = 666
}

variable "smb_directory_mode" {
  type    = number
  default = 777
}

variable "s3_read_write" {
  type    = list(string)
  default = ["*"]
}

# -------------------------------------------------------------------------
# Local lab user (S3 bucket_owner — not the VMS login)
# -------------------------------------------------------------------------

variable "lab_user_name" {
  description = "Local provider username used as S3 bucket_owner"
  type        = string
  default     = "lab"
}

variable "lab_user_uid" {
  description = "UID / leading GID for the lab user"
  type        = number
  default     = 50000
}

# -------------------------------------------------------------------------
# Existing cloud protocols VIP pool (lookup only — do not create)
# -------------------------------------------------------------------------

variable "vip_pool_existing" {
  description = "Name of the cloud-created protocols VIP pool"
  type        = string
  default     = "protocolsPool"
}

variable "vippool_permissions" {
  description = "Permission granted to the view policy on the VIP pool"
  type        = string
  default     = "RW"
}
