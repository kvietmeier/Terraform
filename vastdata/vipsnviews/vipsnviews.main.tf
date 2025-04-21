###===================================================================================###
#
#  File:  vipsnviews.main.tf
#  Created By: Karl Vietmeier
#
#  Terraform Module Code
#  Purpose:  
#     
#  Resources Created:
#    * VIP Pool 
#    * View Policy
#    * Views
# 
###===================================================================================###


# ======================
# VIP Pools
# ======================
resource "vastdata_vip_pool" "protocols" {
  provider     = vastdata.GCPCluster
  name         = var.vip1_name
  role         = var.role1
  subnet_cidr  = var.cidr
  gw_ip        = var.gw1
  ip_ranges {
    start_ip = var.vip1_startip
    end_ip   = var.vip1_endip
  }
}

resource "vastdata_vip_pool" "replication" {
  provider     = vastdata.GCPCluster
  name         = var.vip2_name
  role         = var.role2
  subnet_cidr  = var.cidr
  gw_ip        = var.gw2
  ip_ranges {
    start_ip = var.vip2_startip
    end_ip   = var.vip2_endip
  }
}

# ======================
# View Policy
# ======================
resource "vastdata_view_policy" "vpolicy1" {
  provider      = vastdata.GCPCluster
  name          = var.policy_name
  #vip_pools     = [vastdata_vip_pool.protocols.id]
  flavor        = "MIXED_LAST_WINS"
  use_auth_provider = true
  auth_source   = "RPC_AND_PROVIDERS"
  access_flavor = "ALL"

  # Need at least one no_squash for NFS - even if is no_squash
  nfs_no_squash = ["0.0.0.0/0"]  # Or a specific IP like "10.100.2.50"



  vippool_permissions {
    vippool_id          = vastdata_vip_pool.protocols.id
    vippool_permissions = "RW"
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
