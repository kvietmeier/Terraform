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

variable "block_policy_name" {
  description = "Name of an existing block view policy to use (lookup only — not managed)"
  type        = string
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