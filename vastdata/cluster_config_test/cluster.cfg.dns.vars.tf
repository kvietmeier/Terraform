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

variable "dns_shortname" {
  description = "Prefix for DNS domain"
  type        = string
}
