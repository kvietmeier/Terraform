###==================================================================================###
#
#
#
###==================================================================================###



variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default = "terraform"
}

variable "rgname" {
  description = "Suffix for Resource Group Name"
  default = "resources"
}

variable "location" {
  description = "The Azure Region in which all resource will be created."
  default = "westus2"
}

variable "region" {
  description = "The Azure Region in which all resource will be created."
  default = "westus2"
}

###==================================================================================###
###     Network Configurations
###==================================================================================###

# Address list for NSG
variable whitelist_ips {
  description = "A list of IP CIDR ranges to allow as clients. Do not use Azure tags like `Internet`."
  default     = ["47.144.107.198", "134.134.139.64/27", "134.134.137.64/27", "192.55.54.32/27", "192.55.55.32/27"]
  type        = list(string)
}

###==================================================================================###
###     VM specific information
###==================================================================================###
variable "username" {
  description = "User Name for OS"
  default = "azureuser"
}

variable "password" {
  description = "User Password"
  default = "Chalc0pyrite"
}

variable "vm_size" {
  description = "VM Instance Size"
  default = "Standard_D2s_v5"
}
