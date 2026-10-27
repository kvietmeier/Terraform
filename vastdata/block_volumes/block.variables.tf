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
# Block subsystem views (one per host; we create these)
# -------------------------------------------------------------------------

variable "view_protocols" {
  description = "Protocols for each block view (e.g., [\"BLOCK\"])"
  type        = list(string)
}

variable "view_create_dir" {
  description = "Create each view path directory if missing"
  type        = bool
}

###===================================================================================###
###   Hosts → subsystem → volumes (nested map mirrors the VAST hierarchy)
###===================================================================================###

variable "base_nqn_prefix" {
  description = "Base initiator NQN prefix; full NQN is <prefix>:<hostname> unless hosts.*.nqn is set"
  type        = string
}

variable "hosts" {
  description = <<-EOT
    Hierarchical map: host → subsystem (view) → volumes.
    Key = hostname (e.g. ws-2019bm-01). One subsystem view per host
    (name/path default to <hostname>_block). Nested volumes map keys are
    volume names; size is bytes. NQN defaults to <base_nqn_prefix>:<hostname>.
  EOT
  type = map(object({
    nqn       = optional(string)
    view_name = optional(string)
    view_path = optional(string)
    volumes = map(object({
      size = number
    }))
  }))
}
