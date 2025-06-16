###===================================================================================###
#
#  View Policy variables
#
###===================================================================================###

variable "name" {
  description = "string"
}

variable "flavor" {
  description = "string"
}

variable "vip_pool_name" {
  description = "string"
}

# variable "vip_pools" {
#   description = "integer"
#   type        = list(any)
# }

variable "use_auth_provider" {
  description = ""
  type        = bool
}

variable "nfs_posix_acl" {
  description = ""
  type        = bool
}

variable "auth_source" {
  description = ""
  type        = string
}

variable "nfs_no_squash" {
  type        = list(any)
  description = ""
}

variable "nfs_root_squash" {
  type        = list(any)
  description = ""
}

variable "nfs_all_squash" {
  type        = list(any)
  description = ""
}

variable "trash_access" {
  type        = list(any)
  description = ""
}

variable "read_write" {
  type        = list(any)
  description = ""
}

variable "read_only" {
  type        = list(any)
  description = ""
}

variable "nfs_read_write" {
  type        = list(any)
  description = ""
}

variable "nfs_read_only" {
  type        = list(any)
  description = ""
}

variable "smb_read_write" {
  type        = list(any)
  description = ""
}

variable "smb_read_only" {
  type        = list(any)
  description = ""
}

variable "s3_read_write" {
  type        = list(any)
  description = ""
}

variable "s3_read_only" {
  type        = list(any)
  description = ""
}

variable "s3_visibility" {
  type        = list(any)
  description = ""
}

variable "s3_visibility_groups" {
  type        = list(any)
  description = ""
}

variable "apple_sid" {
  type        = bool
  description = ""
}