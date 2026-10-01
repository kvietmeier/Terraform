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

# Fetch the existing view Block Policy details
data "vastdata_view_policy" "selected_view_policy" {
  name = var.block_policy_name
}

# -------------------------------------------------------------------------
# Own only what we create: view / host / volume / map
# Shared tenant, VIP pool, and block policy are lookups only (never managed)
# -------------------------------------------------------------------------

# 1. Create Block Subsystem View (attaches to existing policy by ID)
resource "vastdata_view" "windows_block_01" {
  path       = var.view_path
  policy_id  = data.vastdata_view_policy.selected_view_policy.id
  protocols  = var.view_protocols
  create_dir = var.view_create_dir
}

# 2. Register Host NQN (our initiator — do not adopt existing Linux/K8s hosts)
resource "vastdata_host" "starwind_ws2019-01" {
  name = var.host_name
  nqn  = var.host_nqn
}

# 3. Provision Volume
resource "vastdata_volume" "win_vol1" {
  name    = var.volume_name
  size    = var.volume_size
  view_id = vastdata_view.windows_block_01.id
}

# 4. Map Volume to Host
resource "vastdata_volume_map" "win_vol1_map" {
  volume_id = vastdata_volume.win_vol1.id
  host_id   = vastdata_host.starwind_ws2019-01.id
}