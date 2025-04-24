###===================================================================================###
#
#  File:  vipsnviews.main.tf
#  Created By: Karl Vietmeier
#
#  Terraform Module Code
#  * VIP Pools (Removed Creation — Now using Data Source)
#
#  Resources Created:
#    * View Policy
#    * Views
# 
###===================================================================================###

# Replace creation with a data source (already defined earlier)
# Example:
# data "vastdata_vip_pool" "protocolsVIP" {
#   provider = vastdata.GCPCluster
#   name     = var.vip_pool_existing
# }


# Use existing VIP Pool
data "vastdata_vip_pool" "protocolsVIP" {
  provider      = vastdata.GCPCluster
  name = var.vip_pool_existing
}


# ======================
# View Policy
# ======================
resource "vastdata_view_policy" "vpolicy1" {
  provider            = vastdata.GCPCluster
  name                = var.policy_name
  flavor              = var.view_policy_flavor
  use_auth_provider   = var.use_auth_provider
  auth_source         = var.auth_source
  access_flavor       = var.access_flavor

  nfs_no_squash       = var.nfs_no_squash
  nfs_read_write      = var.nfs_read_write
  nfs_read_only       = var.nfs_read_only
  smb_read_write      = var.smb_read_write
  smb_read_only       = var.smb_read_only

  vippool_permissions {
    vippool_id          = data.vastdata_vip_pool.protocolsVIP.id
    vippool_permissions = var.vippool_permission_mode
  }
}

# ======================
# Views
# ======================
resource "vastdata_view" "nfs_views" {
  provider   = vastdata.GCPCluster
  count      = var.num_views
  path       = "/${var.path_name}${count.index + 1}"
  protocols  = ["NFS"]
  policy_id  = vastdata_view_policy.vpolicy1.id
  create_dir = true
}
