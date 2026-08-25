# -------------------------------------------------------------------------
# Data Sources (Lookups)
# -------------------------------------------------------------------------

# Fetch the existing Tenant details
data "vastdata_tenant" "selected_tenant" {
  name = var.tenant_name
}

# Fetch the existing VIP Pool details
data "vastdata_vip_pool" "selected_vip_pool" {
  name = var.vip_pool_name
}

# -------------------------------------------------------------------------
# Infrastructure Resources
# -------------------------------------------------------------------------

# 1. Create View Policy
resource "vastdata_view_policy" "win_block_policy" {
  name        = var.policy_name
  tenant_name = data.vastdata_tenant.selected_tenant.name
  vip_pools   = [data.vastdata_vip_pool.selected_vip_pool.name]
  flavor      = var.policy_flavor
  auth_source = var.policy_auth_source
  read_write  = var.policy_read_write
}

# 2. Create Block Subsystem View
resource "vastdata_view" "windows_block_01" {
  path       = var.view_path
  policy_id  = vastdata_view_policy.win_block_policy.id
  protocols  = var.view_protocols
  create_dir = var.view_create_dir
}

# 3. Register Host NQN
resource "vastdata_host" "win_server_01" {
  name = var.host_name
  nqn  = var.host_nqn
}

# 4. Provision Volume
resource "vastdata_volume" "win_vol1" {
  name    = var.volume_name
  size    = var.volume_size
  view_id = vastdata_view.windows_block_01.id 
}

# 5. Map Volume to Host
resource "vastdata_volume_map" "win_vol1_map" {
  volume_id = vastdata_volume.win_vol1.id
  host_id   = vastdata_host.win_server_01.id
}