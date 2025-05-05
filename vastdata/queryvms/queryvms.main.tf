###===================================================================================###
#
#  File:  queryvms.main.tf
#  Created By: Karl Vietmeier
#
#  Terraform Module Code
#  Purpose:  
#     Access cluster config information
#     * Good way to test authentication
# 
###===================================================================================###


###===================================================================================###
#     Query infrastructure resources
###===================================================================================###

# Use existing VIP Pool
data "vastdata_vip_pool" "protocolsVIP" {
  provider      = vastdata.GCPCluster
  name = var.vip_pool_existing
}



###===================================================================================###
#     Output Data
###===================================================================================###
output "protocols_vip_pool_id" {
  value = data.vastdata_vip_pool.protocolsVIP.id
  description = "The ID of the protocols VIP pool."
}

output "protocols_vip_pool_name" {
  value = data.vastdata_vip_pool.protocolsVIP.name
  description = "The name of the protocols VIP pool."
}

output "protocols_vip_pool_tenant_id" {
  value = data.vastdata_vip_pool.protocolsVIP.tenant_id
  description = "The tenant ID associated with the protocols VIP pool."
}

output "protocols_vip_pool_cluster" {
  value = data.vastdata_vip_pool.protocolsVIP.cluster
  description = "The cluster associated with the protocols VIP pool."
}


###===================================================================================###
/*
###--- These weren't valid
output "protocols_vip_pool_cluster_id" {
  value = data.vastdata_vip_pool.protocolsVIP.cluster_id
  description = "The cluster ID associated with the protocols VIP pool."
}

output "protocols_vip_pool_cidr" {
  value = data.vastdata_vip_pool.protocolsVIP.cidr
  description = "The CIDR of the protocols VIP pool."
}

output "protocols_vip_pool_gateway" {
  value = data.vastdata_vip_pool.protocolsVIP.gateway
  description = "The gateway of the protocols VIP pool."
}

output "protocols_vip_pool_ips" {
  value = data.vastdata_vip_pool.protocolsVIP.ips
  description = "The list of IP addresses in the protocols VIP pool."
}

output "protocols_vip_pool_tenant_name" {
  value = data.vastdata_vip_pool.protocolsVIP.tenant_name
  description = "The tenant name associated with the protocols VIP pool."
}
*/
