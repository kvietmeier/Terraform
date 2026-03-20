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
  type        = string
}

variable "zone" {
  description = "Availability Zone"
  type        = string
}

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

###--- Dynamic Firewall Rules

variable "ingress_firewall_rules" {
  description = "A map of custom ingress firewall rules to create."
  type = map(object({
    name        = string
    description = string
    priority    = number
    allow = list(object({
      protocol = string
      ports    = optional(list(string), [])
    }))
    target_tags = optional(list(string), [])
  }))
  default = {}
}

###--- VPC Setup

variable "vpc_name" {
  description = "The name of the VPC network where firewall rules will be applied."
  type        = string
  default     = "default"
}

variable "ingress_filter" {
  description = "A list of source CIDR ranges to allow for ingress rules."
  type        = list(string)
}

###--- Firewall Direction

variable "ingress_rule" {
  description = "The direction for ingress firewall rules."
  type        = string
  default     = "INGRESS"
}

variable "egress_rule" {
  description = "The direction for egress firewall rules."
  type        = string
  default     = "EGRESS"
}

variable "description" {
  description = "General description for firewall rules"
  type        = string
}

###--- Firewall Rule Names

variable "myrules_name" {
  description = "Standard TCP/UDP services rule name"
  type        = string
}

variable "addc_name" {
  description = "Active Directory rule name"
  type        = string
}

variable "vast_rules_name" {
  description = "VAST Data rule name"
  type        = string
}

###--- Priorities

variable "svcs_priority" {
  description = "Priority for standard services"
  type        = number
  default     = 500
}

variable "vast_priority" {
  description = "Priority for VAST rules"
  type        = number
  default     = 500
}

variable "addc_priority" {
  description = "Priority for AD rules"
  type        = number
  default     = 501
}

variable "egress_priority" {
  description = "Priority for egress rules"
  type        = number
  default     = 1000
}

###--- Destination Port Lists

variable "all_ports" {
  description = "Represents all ports for egress"
  type        = string
  default     = "ALL"
}

variable "tcp_ports" {
  description = "Standard TCP ports (SSH, RDP, etc.)"
  type        = list(string)
}

variable "udp_ports" {
  description = "Standard UDP ports"
  type        = list(string)
}

variable "spark_tcp" {
  description = "Ports for Spark"
  type        = list(string)
}

variable "spark_vast_tcp" {
  description = "Ports for VAST Spark"
  type        = list(string)
}

variable "addc_tcp_ports" {
  description = "TCP ports for Active Directory"
  type        = list(string)
}

variable "addc_udp_ports" {
  description = "UDP ports for Active Directory"
  type        = list(string)
}

variable "vast_tcp" {
  description = "TCP ports required for VAST Data"
  type        = list(string)
}

variable "vast_udp" {
  description = "UDP ports required for VAST Data"
  type        = list(string)
}

###--- HA VPN Control Plane Variables

variable "azure_public_ip_01" {
  description = "Public IP of the first Azure VPN gateway for HA VPN."
  type        = string
}

variable "azure_public_ip_02" {
  description = "Public IP of the second Azure VPN gateway for HA VPN."
  type        = string
}