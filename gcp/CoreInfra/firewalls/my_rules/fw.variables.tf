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

variable "ingress_rule" {
  description = "Ingress"
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
  type        = string
}

variable "azure_public_ip_02" {
  description = "The public IP of the second Azure VPN Gateway interface."
  type        = string
}