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
variable "fw_rule_name" {
  description = "Name for rule"
  type        = string
}

variable "description" {
  description = "explanation"
  type        = string
}



# Allow list for Firewall Rules
variable allowed_ranges {
  description = "A list of IPs and CIDR ranges to allow"
  type        = list(string)
}

# Destination Port list
variable tcp_ports {
  description = "A list of standard network services: SSH, FTP, RDP, SMP, etc."
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