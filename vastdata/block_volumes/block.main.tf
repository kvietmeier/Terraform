###===================================================================================###
#
#  File:        block.main.tf
#  Author:      Karl Vietmeier
#
#  Description:
#  Create our own block lab objects on an existing VAST cluster: one shared
#  BLOCK subsystem view, per-client block hosts (initiator NQN), volumes,
#  and host↔volume mappings.
#
#  Shared tenant / VIP pool / view policy are lookups only — never managed.
#  Add hosts/volumes in tfvars incrementally (for_each is idempotent).
#  NQN prefix comes from tfvars (most clients use a standard vendor format).
#
###===================================================================================###

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
# Provider 3.x: vastdata_block_host + vastdata_block_host_mapping
# -------------------------------------------------------------------------

# Shared block subsystem for our volumes
resource "vastdata_view" "windows_block" {
  path       = var.view_path
  name       = var.view_name
  policy_id  = data.vastdata_view_policy.selected_view_policy.id
  protocols  = var.view_protocols
  create_dir = var.view_create_dir
}

# One VAST block host per client server (initiator NQN)
resource "vastdata_block_host" "this" {
  for_each = var.hosts

  name      = each.key
  tenant_id = data.vastdata_tenant.selected_tenant.id
  nqn       = coalesce(each.value.nqn, "${var.base_nqn_prefix}:${each.key}")
}

# Two (or more) volumes per host; name keys like 2019_01_vol1
resource "vastdata_volume" "this" {
  for_each = var.volumes

  name    = each.key
  size    = each.value.size # bytes
  view_id = vastdata_view.windows_block.id
}

# Map each volume to its host
resource "vastdata_block_host_mapping" "this" {
  for_each = var.volumes

  volume_id = vastdata_volume.this[each.key].id
  host_id   = vastdata_block_host.this[each.value.host_key].id
}
