###===================================================================================###
#
#  File:  vipsnviews.outputs.tf
#  Created By: Karl Vietmeier
#
#     Data Sources & Output
# 
###===================================================================================####

/*
data "vastdata_vip_pool" "pool1_gcp" {
  provider = vastdata.GCPCluster
  name     = var.vip1_name
}

output "vip_pool_id_gcp" {
  value = data.vastdata_vip_pool.pool1_gcp.id
}

output "vip_pool_name_gcp" {
  value = data.vastdata_vip_pool.pool1_gcp.name
}
*/