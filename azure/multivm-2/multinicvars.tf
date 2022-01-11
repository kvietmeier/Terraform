###===================================================================================###
#  File:  multinicvars.tf
#  Created By: Karl Vietmeier
#
#  Declare variable types and names
#
#  Files:
#    multinic.tf
#    multinicvars.tf
#    multinic.tfvars
#
#  Usage:
#  terraform apply --auto-approve -var-file=".\multinic.tfvars"
#  terraform destroy --auto-approve -var-file=".\multinic.tfvars"
###===================================================================================###

# Azure Region 
variable "region" { type = string }

# Misc dimensioning/scale parameters
variable "node_count" { type = number }
variable "resource_prefix" { type = string }
variable "vm_prefix" { type = string }


variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default     = "terraform"
  type        = string
}

variable "rgname" {
  description = "Suffix for Resource Group Name"
  default     = "resources"
  type        = string
}


###==================================================================================###
###     Network Configuration
###==================================================================================###

variable "use_public_ip" {
  description = "If set to true, attach a public IP"
  type = bool
}

variable "nics" {type = list(string)}
variable "vnet_cidr" {type = list(string)}
variable "subnet_cidrs" {type = list(string)}


variable "nic_labels" {type = list(string)}
variable "subnet_name" {type = list(string)}
variable "static_ips" {type = list(string)}
variable "ip_alloc" {type = list(string)}
variable "sriov" {type = list(string)}


# Address list for NSG
variable whitelist_ips {
  description = "A list of IP CIDR ranges to allow as clients. Do not use Azure tags like `Internet`."
  default     = ["47.144.107.198", "134.134.139.64/27", "134.134.137.64/27", "192.55.54.32/27", "192.55.55.32/27"]
  type        = list(string)
}


###==================================================================================###
###     VM specific information
###==================================================================================###

variable "vm_size" { type = string }

# OS Image and Disk
variable "publisher" { type = string }
variable "offer" { type = string }
variable "sku" { type = string }
variable "ver" { type = string }
variable "caching" { type = string }
variable "sa_type" { type = string }


# User Info
variable "username" { type = string }
variable "password" { type = string }


###==================================================================================###
# Environment (Tagging)
###==================================================================================###
variable "Environment" { type = string }
