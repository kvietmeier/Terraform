###===================================================================================
# VIP Pool Configuration Variables
###===================================================================================

variable "cidr" {
  description = "CIDR block for VIP subnets"
  type        = string
}

variable "vip1_name" {
  description = "Name of the first VIP Pool"
  type        = string
}

variable "gw1" {
  description = "Gateway for the first subnet"
  type        = string
}

variable "vip1_startip" {
  description = "Start IP for VIP Pool 1"
  type        = string
}

variable "vip1_endip" {
  description = "End IP for VIP Pool 1"
  type        = string
}

variable "role1" {
  description = "Role name for VIP Pool 1"
  type        = string
}

variable "vip2_name" {
  description = "Name of the second VIP Pool"
  type        = string
}

variable "gw2" {
  description = "Gateway for the second subnet"
  type        = string
}

variable "vip2_startip" {
  description = "Start IP for VIP Pool 2"
  type        = string
}

variable "vip2_endip" {
  description = "End IP for VIP Pool 2"
  type        = string
}

variable "role2" {
  description = "Role name for VIP Pool 2"
  type        = string
}
