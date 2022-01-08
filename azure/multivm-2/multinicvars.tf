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

variable "region" {
  description = "The Azure Region in which all resource will be created."
  default     = "westus2"
  type        = string
}

###==================================================================================###
###     Network Configuration
###==================================================================================###

variable "nics" {type = list(string)}
variable "vnet_cidr" {type = list(string)}
variable "subnet_cidrs" {type = list(string)}


variable "nic_labels" {type = list(string)}
variable "subnet_name" {type = list(string)}
variable "ip_addrs" {type = list(string)}
variable "ip_alloc" {type = list(string)}
variable "sriov" {type = list(string)}



###==================================================================================###
###     VM specific information
###==================================================================================###
variable "username" {
  description = "User Name for OS"
  default     = "azureuser"
  type        = string
}

variable "password" {
  description = "User Password"
  default     = "Chalc0pyrite"
  type        = string
}

variable "vm_size" {
  description = "VM Instance Size"
  #default = "Standard_D4s_v5"
  default = "Standard_D4s_v4"
  type        = string
}

variable "node_count" { type = number }