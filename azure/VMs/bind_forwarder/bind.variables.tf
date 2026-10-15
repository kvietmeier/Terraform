###===================================================================================###
#
#  File:  bind.variables.tf
#  Created By: Karl Vietmeier
#
#  Variable definitions — values from tfvars
#
###===================================================================================###

###--- Location / RG

variable "location" {
  description = "Azure region for the forwarder VM and its resource group"
  type        = string
}

variable "resource_group_name" {
  description = "New resource group name for the BIND VM (NIC + disk live here)"
  type        = string
  default     = "bind-vast-fwd-rg"
}

###--- Existing network

variable "network_resource_group_name" {
  description = "Resource group that owns the existing vNet/subnet"
  type        = string
}

variable "vnet_name" {
  description = "Existing virtual network name"
  type        = string
}

variable "subnet_name" {
  description = "Existing subnet name to attach the NIC"
  type        = string
}

variable "vnet_cidr" {
  description = "vNet (or client subnet) CIDR used in named ACL allow-query"
  type        = string
}

variable "additional_query_cidrs" {
  description = "Extra CIDRs allowed to query BIND (named ACL only)"
  type        = list(string)
  default     = []
}

variable "nsg_id" {
  description = "Optional existing NSG ID to associate with the NIC (must allow UDP/TCP 53)"
  type        = string
  default     = null
}

variable "assign_public_ip" {
  description = "Attach a public IP (usually false — use bastion/VPN)"
  type        = bool
  default     = false
}

###--- Instance

variable "vm_name" {
  description = "VM / hostname"
  type        = string
  default     = "bind-vast-fwd"
}

variable "vm_size" {
  description = "VM size — Standard_B1s is enough for a forwarder"
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "Linux admin user (cloud-init also targets ubuntu home for aliases)"
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_key_file" {
  description = "Path to SSH public key file"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Local private key path for formatted ssh output"
  type        = string
  default     = "~/.ssh/id_rsa"
}

variable "os_disk_size_gb" {
  description = "OS disk size in GiB"
  type        = number
  default     = 30
}

variable "ubuntu_sku" {
  description = "Canonical Ubuntu marketplace SKU"
  type        = string
  default     = "24_04-lts-gen2"
}

variable "tags" {
  description = "Resource tags (vast-client / Role merged in locals)"
  type        = map(string)
  default     = {}
}

###--- BIND / VAST DNS

variable "vast_zones" {
  description = "DNS zones to conditionally forward to VAST (no trailing dot)"
  type        = list(string)
}

variable "vast_dns_ips" {
  description = "VAST DNS VIP(s) that host the zone(s)"
  type        = list(string)
}

variable "cloud_resolver" {
  description = "Default cloud DNS (Azure wire server)"
  type        = string
  default     = "168.63.129.16"
}
