variable "vast_host" {
  type        = string
  description = "VAST cluster management VIP or hostname"
}

variable "vast_username" {
  type        = string
  description = "VAST username"
}

variable "vast_password" {
  type        = string
  description = "VAST password"
  sensitive   = true
}

variable "view_policy_name" {
  type        = string
  description = "Name of the VAST view policy"
  default     = "tf-nfs3-no-root-squash-policy"
}

variable "view_path" {
  type        = string
  description = "Path of the VAST view"
  default     = "/terraform/nfs3_view"
}
