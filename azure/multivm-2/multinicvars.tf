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

variable "nics" {}

variable "vnet_prefix" {}

variable "subnet_prefixes" {}


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
  #default = "Standard_D4s_v5"
  default = "Standard_D4s_v4"
}

variable "node_count" { type = number }