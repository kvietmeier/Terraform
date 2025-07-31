###===================================================================================###
#
#  File:  vastdata.variables.tf
#  Created By: Karl Vietmeier
#
#  These are going to be the same for every configuration.
#   
###===================================================================================###
###===================================================================================###
###                            VAST Cluster Provider Variables                        ###
###===================================================================================###

variable "vast_user" {
  description = "Username for the VAST Cluster"
  type        = string
  sensitive   = true
}

variable "vast_port" {
  description = "Port used to connect to the VAST Cluster"
  type        = number
  default     = 443
}

variable "vast_passwd" {
  description = "Password for the VAST Cluster"
  type        = string
  sensitive   = true
}

variable "vast_host" {
  description = "Hostname or IP address of the VAST Cluster"
  type        = string
}

variable "skip_ssl" {
  description = "Boolean to skip SSL certificate verification"
  type        = bool
  default     = false
}

variable "validation_mode" {
  description = "Mode to use for provider version validation"
  type        = string
  default     = "strict"
}


###===================================================================================###
###                            VAST Cluster Variables                                 ###
###===================================================================================###
/* 
variable "vip_pool_existing" {
  description = "The name of the existing VIP Pool to query from the VAST cluster"
  type        = string
}

*/





###===================================================================================###
###                            Convert Data to variables                              ###
###===================================================================================###
/* 
locals {
  protocols_vip_pool_id        = data.vastdata_vip_pool.protocolsVIP.id
  protocols_vip_pool_name      = data.vastdata_vip_pool.protocolsVIP.name
  protocols_vip_pool_tenant_id = data.vastdata_vip_pool.protocolsVIP.tenant_id
  protocols_vip_pool_cluster   = data.vastdata_vip_pool.protocolsVIP.cluster
}
*/