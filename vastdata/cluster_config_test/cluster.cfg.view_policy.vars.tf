###===================================================================================###
#
# View Policy Configuration Variables (View and Access Policies for NFS, SMB, S3)
#
###===================================================================================###


###--- NFS View Policy Variables
variable "flavor" {
  description = "Specifies the view policy flavor"
  type        = string
  default     = "MIXED_LAST_WINS"
}

variable "use_auth_provider" {
  description = "Whether to use an authentication provider"
  type        = bool
  default     = true
}

variable "auth_source" {
  description = "Source for authentication"
  type        = string
  default     = "RPC_AND_PROVIDERS"
}

variable "access_flavor" {
  description = "Access flavor setting"
  type        = string
  default     = "ALL"
}

variable "vippool_permissions" {
  description = "Permissions for the VIP pool (e.g., RW or RO)"
  type        = string
  default     = "RW"
}

variable "nfs_default_policy_name" {
  description = "Name of the VAST view policy"
  type        = string
}

variable "nfs_no_squash" {
  description = "List of CIDRs/IPs for NFS no-root-squash access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "nfs_read_write" {
  description = "List of CIDRs/IPs for NFS read-write access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "nfs_read_only" {
  description = "List of CIDRs/IPs for NFS read-only access"
  type        = list(string)
  default     = []
}

variable "smb_read_write" {
  description = "List of users/groups/IPs for SMB read-write access"
  type        = list(string)
  default     = []
}

variable "smb_read_only" {
  description = "List of users/groups/IPs for SMB read-only access"
  type        = list(string)
  default     = []
}


###--- S3 View Policy Variables
variable "s3_default_policy_name" {
  description = "Name of the VAST S3 view policy"
  type        = string
}

variable "s3_flavor" {
  description = "Specifies the view policy flavor"
  type        = string
  default     = "S3_NATIVE"
}

variable "s3_special_chars_support" {
  description = "Enable object names with special chars incompatible with other protocols"
  type        = bool
  default     = true
}

variable "s3_policy1_file" {
  description = "Path to the S3 policy JSON file"
  type        = string
  default     = "s3Policy1.json"
}

variable "s3_user_policy_name" {
  description = "Name of the S3 user policy"
  type        = string
  default     = "s3user_policy01"
}


###===================================================================================###
#  View Configuration Variables
###===================================================================================###

###--- NFS View Configuration Variables
variable "num_views" {
  description = "Number of views to create"
  type        = number
}

variable "path_name" {
  description = "Base path name for views"
  type        = string
}

variable "protocols" {
  description = "List of protocols to enable"
  type        = list(string)
  default     = ["NFS"]
}

variable "create_dir" {
  description = "Whether to create the export directory automatically"
  type        = bool
  default     = true
}


###--- S3 View Configuration Variables
variable "s3_view_path" {
  description = "Filesystem path for the S3 view"
  type        = string
  default     = "/s3bucket01"
}

variable "s3_view_protocol" {
  description = "Protocol for the View - S3"
  type        = list(string)
  default     = ["S3"]
}

variable "s3_view_name" {
  description = "Name of the S3 view"
  type        = string
  default     = "s3view01"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  default     = "bucket01"
}

variable "s3_default_owner" {
  description = "Name of the S3 Owner"
  type        = string
}

variable "s3_use_ldap_auth" {
  description = "Enable LDAP authentication for S3"
  type        = bool
  default     = false
}

variable "s3_view_create_dir" {
  description = "Whether to create the directory if it does not exist"
  type        = bool
  default     = true
}

variable "s3_view_allow_s3_anonymous" {
  description = "Allow anonymous S3 access"
  type        = bool
  default     = false
}
