###===================================================================================###
# VAST Data VIP Pools and NFS View Configuration
# --role: PROTOCOLS | REPLICATION | VAST_CATALOG
#
# This file defines:
# - VAST provider connection settings
# - Two VIP Pools:
#     - sharesPool (role: PROTOCOLS)
#     - targetPool (role: REPLICATION)
# - Shared network settings
# - NFS view policy configuration
###===================================================================================###


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