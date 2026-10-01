###===================================================================================###
#
#  File:        block.variables.tf
#  Author:      Karl Vietmeier
#
#  Description:
#  Input variables for block_volumes. No defaults here — set values in
#  block.variables.tfvars (and TF_VAR_* for provider auth).
#
###===================================================================================###

# -------------------------------------------------------------------------
# Shared lookups (existing lab objects — never managed by this stack)
# -------------------------------------------------------------------------

variable "tenant_name" {
  description = "Existing tenant name (lookup only)"
  type        = string
}

variable "vip_pool_name" {
  description = "Existing VIP pool name (lookup only; usually on the shared policy)"
  type        = string
}

variable "block_policy_name" {
  description = "Existing block view policy to use (lookup only — not managed)"
  type        = string
}

# -------------------------------------------------------------------------
# Block subsystem view (we create this)
# -------------------------------------------------------------------------

variable "view_path" {
  description = "Mount path for our block subsystem view"
  type        = string
}

variable "view_name" {
  description = "Display name for the block subsystem view"
  type        = string
}

variable "view_protocols" {
  description = "Protocols for the block view (e.g., [\"BLOCK\"])"
  type        = list(string)
}

variable "view_create_dir" {
  description = "Create the view path directory if missing"
  type        = bool
}

###===================================================================================###
###   Hosts and Volumes (we own these; one host per server, volumes mapped per host)
###===================================================================================###

variable "base_nqn_prefix" {
  description = "Base initiator NQN prefix; full NQN is <prefix>:<hostname> unless hosts.*.nqn is set"
  type        = string
}

variable "hosts" {
  description = <<-EOT
    Map of VAST block hosts we own. Key = hostname (e.g. ws-2019bm-01).
    NQN defaults to <base_nqn_prefix>:<hostname> unless overridden.
  EOT
  type = map(object({
    nqn = optional(string)
  }))
}

variable "volumes" {
  description = <<-EOT
    Map of volumes we own. Key = volume name (e.g. 2019_01_vol1).
    size is bytes (provider requires a number). host_key must match var.hosts.
  EOT
  type = map(object({
    size     = number
    host_key = string
  }))
}
