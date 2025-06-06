##===================================================================================
# File:        vipsnviews.variables.tf
# Created By:  Karl Vietmeier
#
# Description: Terraform variable definitions for VAST VIPs and views.
#===================================================================================

#------------------------------------------------------------------------------
# Provider Configuration Variables
#------------------------------------------------------------------------------

variable "vast_username" {
  description = "Username for VAST Data API access"
  type        = string
}

variable "vast_password" {
  description = "Password for VAST Data API access"
  type        = string
  sensitive   = true
}

variable "vast_host" {
  description = "VAST cluster hostname or IP address"
  type        = string
}

variable "vast_port" {
  description = "VAST cluster API port"
  type        = string
  default     = "443"
}

variable "vast_skip_ssl_verify" {
  description = "Skip SSL verification for the VAST provider"
  type        = bool
  default     = true
}

variable "vast_version_validation_mode" {
  description = "API version validation mode (strict, warn, or none)"
  type        = string
  default     = "warn"
}

#------------------------------------------------------------------------------
# VIP Pool Configuration Variables
#------------------------------------------------------------------------------

variable "vip1_name" {
  description = "Name of the first VIP Pool"
  type        = string
}

variable "vip2_name" {
  description = "Name of the second VIP Pool"
  type        = string
}

variable "cidr" {
  description = "CIDR block for VIP subnets"
  type        = string
}

variable "gw1" {
  description = "Gateway for the first subnet"
  type        = string
}

variable "gw2" {
  description = "Gateway for the second subnet"
  type        = string
}

variable "vip1_startip" {
  description = "Start IP for VIP Pool 1"
  type        = string
}

variable "vip1_endip" {
  description = "End IP for VIP Pool 1"
  type        = string
}

variable "vip2_startip" {
  description = "Start IP for VIP Pool 2"
  type        = string
}

variable "vip2_endip" {
  description = "End IP for VIP Pool 2"
  type        = string
}

#------------------------------------------------------------------------------
# View Policy Configuration Variables
#------------------------------------------------------------------------------

variable "role1" {
  description = "Role name for VIP Pool 1"
  type        = string
}

variable "role2" {
  description = "Role name for VIP Pool 2"
  type        = string
}

variable "policy_name" {
  description = "Name of the VAST view policy"
  type        = string
}

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

variable "vippool_permissions" {
  description = "Permissions for the VIP pool (e.g., RW or RO)"
  type        = string
  default     = "RW"
}


#------------------------------------------------------------------------------
# View Configuration Variables
#------------------------------------------------------------------------------

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


#------------------------------------------------------------------------------
# DNS Configuration Variables
#------------------------------------------------------------------------------

variable "dns_name" {
  description = "Name of the DNS configuration"
  type        = string
}

variable "dns_vip" {
  description = "VIP address for the DNS service"
  type        = string
}

variable "dns_domain_suffix" {
  description = "DNS domain suffix"
  type        = string
}

variable "port_type" {
  description = "DNS domain suffix"
  type        = string
  default     = "NORTH_PORT"
}

variable "dns_enabled" {
  description = "Enable DNS"
  type        = bool
  default     = true
}

#------------------------------------------------------------------------------
# User\Tenant Configuration Variables
#------------------------------------------------------------------------------

variable "tenant1_name" {
  description = "VIP address for the DNS service"
  type        = string
  default     = "labusers01"
}

variable "tenants" {
  description = "List of tenants to create"
  type = list(object({
    name             = string
    client_ip_ranges = list(string)
    #vippool_ids      = list(string)
  }))
}

variable "user1_name" {
  description = "VIP address for the DNS service"
  type        = string
  default     = "labuser01"
}

variable "groups" {
  type = list(object({
    name = string
    gid  = number
  }))
  default = [
    { name = "group1", gid = 1000 },
    { name = "group2", gid = 2000 },
    { name = "group3", gid = 3000 }
  ]
}

variable "users" {
  type = list(object({
    name               = string
    uid                = number
    leading_group_name = string
    supplementary_groups = list(string)
  }))
  default = [
    {
      name               = "user1"
      uid                = 1111
      leading_group_name = "group1"
      supplementary_groups = ["group2", "group3"]
    }
  ]
}
