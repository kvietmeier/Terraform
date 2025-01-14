###===================================================================================###
#
#  File:  fw.variables.tf
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

variable "rule_direction" {
  description = "Ingress or Egress"
  type        = string
  default     = "INGRESS"
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

variable "addc_name" {
  description = "Standard TCP/UDP services"
  type        = string
}

variable "apprules_name" {
  description = "Standard TCP/UDP services"
  type        = string
}


###--- Priorities
variable "svcs_priority" {
  description = "Priority on stack"
  type        = string
  default     = "500"
}

variable "app_priority" {
  description = "Priority on stack"
  type        = string
  default     = "500"
}

variable "addc_priority" {
  description = "AD rule priority on stack"
  type        = string
  default     = "501"
}

###--- Destination Port lists
variable tcp_ports {
  description = "A list of standard network services: SSH, FTP, RDP, SMP, etc."
  type        = list(string)
}

variable udp_ports {
  description = "A list of standard network services: SSH, FTP, RDP, SMP, etc."
  type        = list(string)
}

variable addc_tcp_ports {
  description = "A list of standard network services: SSH, FTP, RDP, SMP, etc."
  type        = list(string)
}

variable addc_udp_ports {
  description = "A list of standard network services: SSH, FTP, RDP, SMP, etc."
  type        = list(string)
}

variable app_tcp {
  description = "A list of ports needed for Apps"
  type        = list(string)
}
