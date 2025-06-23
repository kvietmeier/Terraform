###===================================================================================###
# VAST Data VIP Pools and NFS View Configuration
# --role: PROTOCOLS | REPLICATION | VAST_CATALOG
#
# This file defines:
# - VAST provider connection settings
# - Two VIP Pools:
#     - sharesPool (role: PROTOCOLS)
#     - targetPool (role: REPLICATION)
# - Shared network settings
# - NFS view policy configuration
###===================================================================================###


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

variable "cidr" {
  description = "CIDR block for VIP subnets"
  type        = string
}

# VIP 1
variable "vip1_name" {
  description = "Name of the first VIP Pool"
  type        = string
}

variable "gw1" {
  description = "Gateway for the first subnet"
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

variable "dns_shortname" {
  description = "Prefix for DNS domain"
  type        = string
}

variable "role1" {
  description = "Role name for VIP Pool 1"
  type        = string
}


# VIP 2
variable "vip2_name" {
  description = "Name of the second VIP Pool"
  type        = string
}

variable "gw2" {
  description = "Gateway for the second subnet"
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

variable "role2" {
  description = "Role name for VIP Pool 2"
  type        = string
}


### Common View/Policy Settings
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


#------------------------------------------------------------------------------
# NFS View Policy Configuration Variables
#------------------------------------------------------------------------------
### NFS Specific
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


#------------------------------------------------------------------------------
# NFS View Configuration Variables
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

###------------------------------------------------------------------------------
#    S3 View Configuration Variables
####------------------------------------------------------------------------------

###--- Default View Policy

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
  description = "This will enable object names that contain “//“ or “/../“ and are incompatible with other protocols"
  type        = bool
  default     = true
}




###--- Default View
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
  description = "Name of the S3 view"
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


###--- User View Policy in json
variable "s3_policy1_file" {
  description = "Path to the S3 policy JSON file"
  type        = string
  default     = "s3Policy1.json"
}

variable "s3_user_policy_name" {
  description = "Name of the S3 view"
  type        = string
  default     = "s3bucket01"
}


#variable "tenant" {
#  description = "Tenant name to associate with the view"
#  type        = string
#  default     = ""
#}


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

#------------------------------------------------------------------------------
# Active Directory
#------------------------------------------------------------------------------

variable "ou_name" {
  description = "Machine account name used to join the AD domain"
  type        = string
}

variable "ad_ou" {
  description = "Distinguished name of the OU in Active Directory"
  type        = string
}

variable "use_ad" {
  description = "Enable Active Directory integration"
  type        = bool
  default     = true
}

variable "bind_dn" {
  description = "Bind DN used to connect to Active Directory"
  type        = string
}

variable "bindpw" {
  description = "Password for the bind DN"
  type        = string
  sensitive   = true
}

variable "ldap" {
  description = "Use LDAPS (true) or LDAP (false)"
  type        = bool
  default     = true
}

variable "ad_domain" {
  description = "FQDN of the Active Directory domain"
  type        = string
}

variable "method" {
  description = "Authentication method (e.g., simple or sasl)"
  type        = string
  default     = "simple"
}

variable "query_mode" {
  description = "Group membership query mode"
  type        = string
  default     = "tokenGroups"
}

variable "use_tls" {
  description = "Use StartTLS with LDAP"
  type        = bool
  default     = true
}

# Optional
variable "ldap_urls" {
  description = "List of LDAP/LDAPS URLs for manual configuration"
  type        = list(string)
  default     = []
}
