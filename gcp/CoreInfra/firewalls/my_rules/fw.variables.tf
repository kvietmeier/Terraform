###===================================================================================###
#  File:        fw.variables.tf
#  Author:      Karl Vietmeier 
#  Purpose:     Variable definitions for custom firewall rules.
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

###--- External and Demo-Specific Port Lists

variable "external_ingress_tcp" {
  description = "Subset of TCP ports allowed for external/on-prem ingress"
  type        = list(string)
}

variable "external_ingress_udp" {
  description = "Subset of UDP ports allowed for external/on-prem ingress"
  type        = list(string)
}

###--- External and Demo-Specific IP CIDRs

variable "gcp_service_cidrs" {
  description = "Static GCP Service ranges (e.g., Health Checks: 130.211.0.0/22, 35.191.0.0/16, IAP: 35.235.240.0/20)"
  type        = list(string)
}

variable "external_ingress" {
  description = "External/On-prem CIDRs that require access to VAST via external rules"
  type        = list(string)
}