###===================================================================================###
#  File:        fw.variables.tf
#  Author:      Karl Vietmeier (Refactored by Gemini Code Assist)
#
#  File:  fw.variables.tf
#  Created By: Karl Vietmeier
#  Purpose:     Variable definitions for custom firewall rules.
#
#  Variable definitions with defaults
#  Structure:
#    - `ingress_firewall_rules`: A map of rule objects to dynamically create firewall
#      rules, reducing code duplication.
#    - `vpc_name`: The target VPC for the firewall rules.
#    - `ingress_filter`: Source IP ranges for ingress traffic.
#    - HA VPN specific variables for the BGP peering connection.
#
###===================================================================================###

###--- Provider Info
variable "region" {
  description = "Region to deploy resources"
variable "ingress_firewall_rules" {
  description = "A map of custom ingress firewall rules to create."
  type = map(object({
    name        = string
    description = string
    priority    = number
    allow = list(object({
      protocol = string
      ports    = optional(list(string))
    }))
    target_tags = optional(list(string))
  }))
  default = {}
}

variable "zone" {
  description = "Availbility Zone"
}

variable "project_id" {
  description = "GCP Project ID"
}


###--- VPC Setup
variable "vpc_name" {
  description = "Name of VPC"
  description = "The name of the VPC network where firewall rules will be applied."
  type        = string
  default     = "default"
}

variable "ingress_filter" {
  description = "A list of source CIDR ranges to allow for ingress rules."
  type        = list(string)
}

###--- Firewall

variable "ingress_rule" {
  description = "Ingress"
  description = "The direction for the firewall rules (e.g., INGRESS)."
  type        = string
  default     = "INGRESS"
}

variable "egress_rule" {
  description = "Egress"
  type        = string
  default     = "ERESS"
}

variable "description" {
  description = "Setup ports and filters"
  type        = string
}

variable ingress_filter {
  description = "A list of IPs and CIDR ranges to allow"
  type        = list(string)
}

# Firewall Rule Names
variable "myrules_name" {
  description = "Standard TCP/UDP services"
  type        = string
}

#variable "ipv6_myrules_name" {
#  description = "Standard TCP/UDP services"
#  type        = string
#}

variable "addc_name" {
  description = "Standard TCP/UDP services"
  type        = string
}

variable "vast_rules_name" {
  description = "Standard TCP/UDP services"
  type        = string
}


###--- Priorities
variable "svcs_priority" {
  description = "Priority on stack"
  type        = string
  default     = "500"
}

variable "vast_priority" {
  description = "Priority on stack"
  type        = string
  default     = "500"
}

variable "addc_priority" {
  description = "AD rule priority on stack"
  type        = string
  default     = "501"
}

variable "egress_priority" {
  description = "Priority for egress rules"
  type        = string
  default     = "1000"
}

###--- Destination Port lists
variable all_ports {
  description = "For egress - everything"
  type        = string
  default     = "ALL"
}

variable tcp_ports {
  description = "A list of standard network services: SSH, FTP, RDP, SMP, etc."
  type        = list(string)
}

variable udp_ports {
  description = "A list of standard network services: SSH, FTP, RDP, SMP, etc."
  type        = list(string)
}

variable spark_tcp {
  description = "Ports for Spark"
  type        = list(string)
}

variable spark_vast_tcp{
  description = "Ports for VAST Spark"
  type        = list(string)
}

variable addc_tcp_ports {
  description = "TCP Ports for Active Directory"
  type        = list(string)
}

variable addc_udp_ports {
  description = "UDP Ports for Active Directory"
  type        = list(string)
}

variable vast_tcp {
  description = "A list of TCP ports needed for VAST Data"
  type        = list(string)
}

variable vast_udp {
  description = "A list of UDP ports needed for VAST Data"
  type        = list(string)
}


# --- HA VPN Control Plane Variables ---
variable "azure_public_ip_01" {
  description = "The public IP of the first Azure VPN Gateway interface."
  description = "Public IP of the first Azure VPN gateway for HA VPN."
  type        = string
}

variable "azure_public_ip_02" {
  description = "The public IP of the second Azure VPN Gateway interface."
  description = "Public IP of the second Azure VPN gateway for HA VPN."
  type        = string
}