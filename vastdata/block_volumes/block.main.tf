# -------------------------------------------------------------------------
# Data Sources (Lookups — shared lab objects, never managed)
# -------------------------------------------------------------------------

data "vastdata_tenant" "selected_tenant" {
  name = var.tenant_name
}

data "vastdata_vip_pool" "selected_vip_pool" {
  name = var.vip_pool_name
}

data "vastdata_view_policy" "selected_view_policy" {
  name = var.block_policy_name
}

# -------------------------------------------------------------------------
# Own only what we create: view / hosts / volumes / maps
# Add host/volume keys in tfvars as you go (idempotent for_each)
# -------------------------------------------------------------------------

# Shared block subsystem for our Windows/StarWind volumes
resource "vastdata_view" "windows_block" {
  path       = var.view_path
  policy_id  = data.vastdata_view_policy.selected_view_policy.id
  protocols  = var.view_protocols
  create_dir = var.view_create_dir
}

# One VAST host per client server (initiator NQN)
resource "vastdata_host" "this" {
  for_each = var.hosts

  name = each.key
  nqn  = coalesce(each.value.nqn, "nqn.2008-08.com.starwind:${each.key}")
}

# Two (or more) volumes per host; name keys like 2019_01_vol1
resource "vastdata_volume" "this" {
  for_each = var.volumes

  name    = each.key
  size    = each.value.size
  view_id = vastdata_view.windows_block.id
}

# Map each volume to its host
resource "vastdata_volume_map" "this" {
  for_each = var.volumes

  volume_id = vastdata_volume.this[each.key].id
  host_id   = vastdata_host.this[each.value.host_key].id
}
