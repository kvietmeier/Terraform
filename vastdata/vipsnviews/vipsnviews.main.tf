terraform {
  required_providers {
    vastdata = {
      source  = "vast-data/vastdata"
      version = "1.4.1"
    }
  }
}

provider "vastdata" {
  username                = "admin"
  port                    = "443"
  password                = "123456"
  host                    = "10.100.2.86"
  skip_ssl_verify         = true
  version_validation_mode = "warn"
  alias                   = "GCPCluster"
}

# ======================
# Variables
# ======================
variable "vip1_name"     { default = "DataSharesPool" }
variable "vip2_name"     { default = "ReplicationPool" }
variable "cidr"          { default = "24" }
variable "gw1"           { default = "33.20.1.1" }
variable "gw2"           { default = "33.21.1.1" }
variable "vip1_startip"  { default = "33.20.1.10" }
variable "vip1_endip"    { default = "33.20.1.21" }
variable "vip2_startip"  { default = "33.21.1.10" }
variable "vip2_endip"    { default = "33.21.1.15" }
variable "role1"         { default = "PROTOCOLS" }
variable "role2"         { default = "REPLICATION" }
variable "policy_name"   { default = "NFS_policy" }
variable "num_views"     { default = 6 }
variable "path_name"     { default = "share" }

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

# ======================
# Data Source & Output
# ======================
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