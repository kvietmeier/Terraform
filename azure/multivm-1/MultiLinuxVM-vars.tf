###===================================================================================###
#  From:
#  https://medium.com/@yoursshaan2212/terraform-to-provision-multiple-azure-virtual-machines-fab0020b4a6e
#
#  Files:
#    MultiLinuxVMs.tf
#    MultiLinuxVMs-vars.tf
#    MultiLinuxVMs-vars.tfvars
#
#    Declare variable types and names
#
#  Usage:
#  terraform apply -var-file=".\MultiLinuxVM-vars.tfvars"
#  terraform destroy -var-file=".\MultiLinuxVM-vars.tfvars"
###===================================================================================###

# Azure Region 
variable "region" { type = string }

# Misc dimensioning/scale parameters
variable "resource_prefix" { type = string }
variable "vm_prefix" { type = string }
variable "node_count" { type = number }


###--- Networking
# vnet CIDR
variable "node_address_space" {
    default = ["10.50.0.0/22"]
}

# Subnet definition 
variable "node_address_prefix" {
    default = ["10.50.1.0/24"]
}

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
