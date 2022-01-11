###==================================================================================###
#
#
#
###==================================================================================###


###===================================================================================###
###  Infrastructure
###===================================================================================###

# Azure Region 
variable "region" { type = string }

# Misc dimensioning/scale parameters
variable "resource_prefix" { type = string }
variable "vm_prefix" { type = string }
variable "node_count" { type = number }


###===================================================================================###
###  Networking
###===================================================================================###

# IP Ranges
variable "vnet_cidr" {type = list(string)}
variable "subnet_cidrs" {type = list(string)}
variable "subnet1_ips" {type = list(string)}
variable "subnet2_ips" {type = list(string)}

# Allow list for NSG
variable whitelist_ips {
  description = "A list of IP CIDR ranges to allow as clients. Do not use Azure tags like `Internet`."
  type        = list(string)
}

# NIC Parameters
variable "nic_labels" {type = list(string)}
variable "subnet_name" {type = list(string)}
variable "ip_alloc" {type = list(string)}
variable "sriov" {type = list(string)}


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

