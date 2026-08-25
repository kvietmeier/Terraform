# -------------------------------------------------------------------------
# Variables Configuration (No defaults allowed here)
# -------------------------------------------------------------------------

variable "tenant_name" {
  description = "The name of the existing tenant"
  type        = string
}

variable "vip_pool_name" {
  description = "The name of the VIP Pool for network isolation"
  type        = string
}

variable "policy_name" {
  description = "The name of the view policy"
  type        = string
}

variable "policy_flavor" {
  description = "The flavor of the policy (e.g., NFS, SMB, MIXED)"
  type        = string
}

variable "policy_auth_source" {
  description = "The authentication source (e.g., RPC, AD, LDAP)"
  type        = string
}

variable "policy_read_write" {
  description = "List of hosts or networks with read/write access"
  type        = list(string)
}

variable "view_path" {
  description = "The mount path for the block view"
  type        = string
}

variable "view_protocols" {
  description = "List of protocols allowed on this view (e.g., BLOCK, NFS)"
  type        = list(string)
}

variable "view_create_dir" {
  description = "Whether to create the directory path if it does not exist"
  type        = bool
}

variable "host_name" {
  description = "The name of the target host"
  type        = string
}

variable "host_nqn" {
  description = "The NVMe Qualified Name (NQN) for the host"
  type        = string
}

variable "volume_name" {
  description = "The name of the block volume"
  type        = string
}

variable "volume_size" {
  description = "The size of the volume (e.g., 2TB)"
  type        = string
}