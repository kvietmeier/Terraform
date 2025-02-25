###===================================================================================###
#
#  File:  Template.tf
#  Created By: Karl Vietmeier
#
#  Terraform Module Code
#  Purpose:  
# 
#  Files in Module:
#    main.tf
#    variables.tf
#    variables.tfvars
#
###===================================================================================###


/* 
  
Usage:
terraform plan -var-file=".\multivm_map.tfvars"
terraform apply --auto-approve -var-file=".\multivm_map.tfvars"
terraform destroy --auto-approve -var-file=".\multivm_map.tfvars"

*/


###===================================================================================###
#     Start creating infrastructure resources
###===================================================================================###

# Want to use existing VIP Pool
data "vastdata_vip_pool" "protocolsVIP" {
    name = "protocolsPool"
}

resource "vastdata_view_policy" "ViewPolicy01" {
  name          = "ViewPolicy01"
  vip_pools     = [data.vastdata_vip_pool.protocolsVIP.id]
  tenant_id     = data.vastdata_vip_pool.protocolsVIP.tenant_id
  flavor        = "NFS"
  nfs_no_squash = ["10.0.0.1", "10.0.0.2"]
}

resource "vastdata_view" "elbencho_view" {
  path       = "/vast/share01"
  policy_id  = vastdata_view_policy.ViewPolicy01.id
  create_dir = "true"
  protocols  = ["NFS", "NFS4"]
}




###===================================================================================###
#     Output info about it
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
