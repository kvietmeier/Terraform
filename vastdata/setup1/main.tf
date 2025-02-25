###===================================================================================###
#
#  File:  main.tf
#  Created By: Karl Vietmeier
#
#  Terraform Module Code
#  Purpose:  
#     Create objects in a VAST cluster
# 
###===================================================================================###


###===================================================================================###
#     Start creating infrastructure resources
###===================================================================================###

# Want to use existing VIP Pool
data "vastdata_vip_pool" "protocolsVIP" {
    name = "protocolsPool"
}

# Need a View Policy
resource "vastdata_view_policy" "ViewPolicy01" {
  name          = "ViewPolicy01"
  vip_pools     = [data.vastdata_vip_pool.protocolsVIP.id]
  tenant_id     = data.vastdata_vip_pool.protocolsVIP.tenant_id
  flavor        = "NFS"
  nfs_no_squash = ["client-vm1.c.clouddev-itdesk124.internal",
                   "client-vm2.c.clouddev-itdesk124.internal",
                   "client-vm3.c.clouddev-itdesk124.internal"
                  ]
}

# Create the View
resource "vastdata_view" "elbencho_view" {
  path       = "/vast/share01"
  policy_id  = vastdata_view_policy.ViewPolicy01.id
  create_dir = "true"
  protocols  = ["NFS", "NFS4"]
}




###===================================================================================###
#     Output info about it - place holder code
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
