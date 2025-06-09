###===================================================================================###
# VAST Data Cluser basic setup for demo/POC
#
# Notes:
# --role: PROTOCOLS | REPLICATION | VAST_CATALOG
#
# This file defines:
# - VAST provider connection settings
# - Two VIP Pools:
#     - sharesPool (role: PROTOCOLS)
#     - targetPool (role: REPLICATION)
# - Shared network settings
# - NFS view policy configuration
# - DNS
###===================================================================================###

# ======================
# VIP Pools
# ======================
resource "vastdata_vip_pool" "protocols" {
  provider     = vastdata.GCPCluster
  name         = var.vip1_name
  domain_name  = var.dns_domain_suffix
  role         = var.role1
  subnet_cidr  = var.cidr
  gw_ip        = var.gw1
  ip_ranges {
    start_ip = var.vip1_startip
    end_ip   = var.vip1_endip
  }

  depends_on = [vastdata_dns.protocol_dns]
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
  provider          = vastdata.GCPCluster
  name              = var.policy_name
  #vip_pools         = [vastdata_vip_pool.protocols.id]
  flavor            = var.flavor
  use_auth_provider = var.use_auth_provider
  auth_source       = var.auth_source
  access_flavor     = var.access_flavor

  # Required NFS squash/no-squash settings
  nfs_no_squash     = var.nfs_no_squash
  nfs_read_write    = var.nfs_read_write
  nfs_read_only     = var.nfs_read_only
  smb_read_write    = var.smb_read_write
  smb_read_only     = var.smb_read_only
  
  vippool_permissions {
    vippool_id          = vastdata_vip_pool.protocols.id
    vippool_permissions = var.vippool_permissions
  }
}

# ======================
# Views
# ======================
resource "vastdata_view" "nfs_views" {
  provider   = vastdata.GCPCluster
  policy_id  = vastdata_view_policy.vpolicy1.id
  count      = var.num_views
  path       = "/${var.path_name}${count.index + 1}"
  protocols   = var.protocols
  create_dir  = var.create_dir
}

# ======================
#  Create dns with ip 11.0.0.1 for domain mu.example.com
# ======================
resource "vastdata_dns" "protocol_dns" {
  provider      = vastdata.GCPCluster
  name          = var.dns_name
  vip           = var.dns_vip
  net_type      = var.port_type
  domain_suffix = var.dns_domain_suffix
  enabled       = var.dns_enabled
}
