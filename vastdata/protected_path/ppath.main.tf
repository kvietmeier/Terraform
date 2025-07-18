###===================================================================================###
#
#  File:  main.tf
#  Created By: Karl Vietmeier
#
#  Terraform Module Code
#  Purpose:  
#     Create protected path/view for GNS
#     https://registry.terraform.io/providers/vast-data/vastdata/latest/docs/resources/protected_path
#     
#     Resources required:
#      * 2 Providers - one for each cluster
#      * VIP Pool (use existing) 
#      * View Policy
#      * View
#      * Protection Policy
#      * Tenant from remote cluster  (use existing?)
#      * Protected Path View
# 
###===================================================================================###


###===================================================================================###
#     Start creating infrastructure resources
###===================================================================================###

# Use existing VIP Pool
data "vastdata_vip_pool" "protocolsVIP" {
  provider      = vastdata.GCPCluster
  name = var.vip_pool_existing
}

# View Policy
resource "vastdata_view_policy" "ViewPolicy01" {
  provider      = vastdata.GCPCluster
  vip_pools     = [data.vastdata_vip_pool.protocolsVIP.id]
  tenant_id     = data.vastdata_vip_pool.protocolsVIP.tenant_id
  name          = var.view_policy_name
  flavor        = var.policy_flavor
  nfs_no_squash = var.nfs_clients
}

# View
resource "vastdata_view" "gns_view" {
  policy_id  = vastdata_view_policy.ViewPolicy01.id
  path       = var.share_path
  create_dir = var.dir_create
  protocols  = var.view_protocols
}

# Protection Policy
resource "vastdata_protection_policy" "protection-policy" {
  provider         = vastdata.GCPCluster
  name             = "protection-policy-1"
  clone_type       = "NATIVE_REPLICATION"
  indestructible   = "false"
  prefix           = "policy-1"
  target_object_id = vastdata_replication_peers.clusterA-clusterB-peer.id

  frames {
    every       = "1D"
    keep_local  = "2D"
    keep_remote = "3D"
    start_at    = "2023-06-04 09:00:00"
  }
}

# Remote Tenant  (use data?)
resource "vastdata_tenant" "tenant_remote_cluster" {
  name     = "default"
  provider = vastdata.RemoteCluster
}

# Protected Path View
resource "vastdata_protected_path" "protected_path_view" {
  name                 = "protected-path-view"
  source_dir           = vastdata_view.view.path
  tenant_id            = vastdata_view.view.tenant_id
  target_exported_dir  = "/view1"
  protection_policy_id = vastdata_protection_policy.protection-policy.id
  remote_tenant_guid   = vastdata_tenant.tenant-clusterB.guid
  target_id            = vastdata_protection_policy.protection-policy.target_object_id

}




