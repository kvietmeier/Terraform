###===================================================================================
# Provider Configuration Variables
###===================================================================================

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

###===================================================================================
# DNS Configuration Variables
###===================================================================================

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
  description = "What port to assign the service to (EXTERNAL_PORT, NORTH_PORT)"
  type        = string
  default     = "NORTH_PORT"
}

variable "dns_enabled" {
  description = "Enable DNS"
  type        = bool
  default     = true
}

/* variable "dns_shortname" {
  description = "Prefix for DNS domain"
  type        = string
}

 */
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
