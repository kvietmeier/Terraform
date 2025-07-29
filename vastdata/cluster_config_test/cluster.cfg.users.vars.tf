###===================================================================================
# User, Group, Tenant Configuration Variables
###===================================================================================

variable "groups" {
  description = "Map of groups to create"
  type = map(object({
    gid = number
  }))
}

variable "users" {
  description = "Map of users to create"
  type = map(object({
    uid                  = number
    leading_group_name   = string
    supplementary_groups = list(string)
    allow_create_bucket  = optional(bool, false)
    allow_delete_bucket  = optional(bool, false)
    s3_superuser         = optional(bool, false)
  }))
}

variable "tenants" {
  description = "Map of tenants to create"
  type = map(object({
    client_ip_ranges = list(object({
      start_ip = string
      end_ip   = string
    }))
    vippool_ids = optional(list(string))
  }))
}

###===================================================================================
# Active Directory Configuration Variables
###===================================================================================

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

variable "ldap_urls" {
  description = "List of LDAP/LDAPS URLs for manual configuration"
  type        = list(string)
  default     = []
}

