variable "network" {
  description = "VPC network name or self_link"
  type        = string
}

variable "description" {
  description = "General description for standard services firewall rule"
  type        = string
  default     = "Setup common ports and service FW rules for the core VPC"
}

variable "ingress_rule" {
  type    = string
  default = "INGRESS"
}

variable "myrules_name" {
  type    = string
  default = "core-firewall-rules"
}

variable "addc_name" {
  type    = string
  default = "ad-rules"
}

variable "vast_rules_name" {
  type    = string
  default = "vast-rules"
}

variable "svcs_priority" {
  type    = number
  default = 500
}

variable "vast_priority" {
  type    = number
  default = 500
}

variable "addc_priority" {
  type    = number
  default = 501
}

variable "ingress_filter" {
  description = "Trusted source CIDRs for standard services / AD"
  type        = list(string)
}

variable "tcp_ports" {
  type = list(string)
}

variable "udp_ports" {
  type = list(string)
}

variable "spark_tcp" {
  type = list(string)
}

variable "spark_vast_tcp" {
  type = list(string)
}

variable "addc_tcp_ports" {
  type = list(string)
}

variable "addc_udp_ports" {
  type = list(string)
}

variable "external_ingress_tcp" {
  type = list(string)
}

variable "external_ingress_udp" {
  type = list(string)
}

variable "gcp_service_cidrs" {
  type = list(string)
}

variable "external_ingress" {
  type = list(string)
}

variable "enable_deny_public_ingress" {
  description = "Create deny-public-ingress rule for no-public-access tagged VMs"
  type        = bool
  default     = true
}
