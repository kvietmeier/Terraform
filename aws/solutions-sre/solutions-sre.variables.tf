###===================================================================================###
#
#  File:  solutions-sre.variables.tf
#  Created By: Karl Vietmeier
#
#  STATUS: NOT TESTED — generic template only. Validate before production apply.
#
#  All inputs via tfvars / TF_VAR_* — nothing org- or account-specific hard-coded.
#
###===================================================================================###

variable "region" {
  description = "IAM Identity Center home region (where permission sets live)"
  type        = string
}

variable "permission_set_name" {
  description = "SSO permission set name (org-specific; set in tfvars)"
  type        = string
  default     = "Solutions-SRE"
}

variable "permission_set_description" {
  description = "Human-readable description shown in Identity Center"
  type        = string
  default     = "Solutions / SA / SRE lane: workloads inside platform-provided VPCs (not CI/QA)."
}

variable "session_duration" {
  description = "Permission set session duration (ISO-8601)"
  type        = string
  default     = "PT8H"
}

variable "relay_state" {
  description = "Optional console relay state URL"
  type        = string
  default     = null
}

variable "attach_readonly_managed_policy" {
  description = "Attach AWS managed ReadOnlyAccess for Describe/List hygiene"
  type        = bool
  default     = true
}

variable "iam_path_prefix" {
  description = "IAM path/ARN prefix this lane may manage (roles/policies/instance-profiles)"
  type        = string
  default     = "solutions"
}

variable "s3_bucket_prefixes" {
  description = "S3 bucket name prefixes this lane may create/use (demo + terraform state). Empty = no S3 write statements."
  type        = list(string)
  default     = ["solutions-demo-", "solutions-tfstate-"]
}

variable "dynamodb_lock_table_prefixes" {
  description = "DynamoDB table name prefixes for Terraform state locking. Empty = no DynamoDB statements."
  type        = list(string)
  default     = ["solutions-tfstate-lock"]
}

variable "idc_group_display_name" {
  description = "Display name hint for the IdC group used in outputs (cosmetic only)"
  type        = string
  default     = "Solutions-SRE"
}

variable "account_assignments" {
  description = <<-EOT
    Map of assignments: key = unique name.
    Each entry targets an AWS account and an Identity Center group (preferred) or user.
    principal_type = GROUP | USER
    principal_id   = Identity Store group/user UUID
  EOT
  type = map(object({
    account_id     = string
    principal_type = string
    principal_id   = string
  }))
  default = {}
}

variable "tags" {
  description = "Tags applied to the permission set"
  type        = map(string)
  default = {
    ManagedBy = "terraform"
    Lane      = "solutions-sre"
    Status    = "untested-template"
  }
}
