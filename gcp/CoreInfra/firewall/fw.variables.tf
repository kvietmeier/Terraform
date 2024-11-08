###===================================================================================###
#
#  File:  vpc.variables.tf
#  Created By: Karl Vietmeier
#
#  Variable definitions with defaults
#
###===================================================================================###

###--- Provider Info
variable "region" {
  description = "Region to deploy resources"
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
  type        = string
  default     = "default"
}


###--- Firewall
# FW Name
variable "stdservices_rules_name" {
  description = "Name for rule"
  type        = string
}

variable "app_rules_name" {
  description = "Name for rule"
  type        = string
}

variable "fw_rule_name" {
  description = "Name for rule"
  type        = string
}

variable "description" {
  description = "Setup ports and filters"
  type        = string
}

variable "rule_direction" {
  description = "Ingress or Egress"
  type        = string
  default     = "INGRESS"
}

variable "rule_priority_services" {
  description = "Priority on stack"
  type        = string
  default     = "500"
}

variable "rule_priority_app" {
  description = "Priority on stack"
  type        = string
  default     = "500"
}

variable "rule_priority" {
  description = "Priority on stack"
  type        = string
  default     = "500"
}


# Allow list for Firewall Rules
variable allowed_ranges {
  description = "A list of IPs and CIDR ranges to allow"
  type        = list(string)
}

variable allowed_services {
  description = "A list of IPs and CIDR ranges to allow for standard services"
  type        = list(string)
}

variable allowed_app {
  description = "A list of IPs and CIDR ranges to allow for Apps"
  type        = list(string)
}

# Destination Port lists
variable tcp_ports {
  description = "A list of standard network services: SSH, FTP, RDP, SMP, etc."
  type        = list(string)
}

variable app_ports {
  description = "A list of ports needed for Apps"
  type        = list(string)
}

variable udp_ports {
  description = "A list of standard network services: SSH, FTP, RDP, SMP, etc."
  type        = list(string)
}

# Network Protocol
#variable "net_protocol" {
#  description = "Network protocol"
#  type        = string
#  default     = "tcp"
#}