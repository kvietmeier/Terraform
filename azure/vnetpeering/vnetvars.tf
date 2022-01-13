# This will Peer two existing VNets across regions

##
# Account Inputs 
##

variable "subscription_id" {
  type = string
}

##
# Input 
##
variable "allow_gateway_transit" {
  type    = string
  default = false
}

variable "use_remote_gateways" {
  type    = string
  default = false
}

variable "allow_forwarded_traffic" {
  type    = string
  default = false
}

variable "allow_virtual_network_access" {
  type    = string
  default = true
}

variable "source_peer" {
 type = object({
    resource_group_name       = string
    virtual_network_name      = string
    remote_virtual_network_id = string
    name                      = string
  })
}

variable "destination_peer" {
 type = object({
    resource_group_name       = string
    virtual_network_name      = string
    remote_virtual_network_id = string
    name                      = string   
  })
}