###===================================================================================###
#
#  File:        block.main.tf
#  Author:      Karl Vietmeier
#
#  Description:
#  Create our own block lab objects on an existing VAST cluster.
#  Hierarchy: host → subsystem (view) → volumes → host↔volume mapping.
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

locals {
  # Per-host subsystem naming; override with hosts.*.view_name / view_path
  host_views = {
    for k, h in var.hosts : k => {
      name = coalesce(h.view_name, "${k}_block")
      path = coalesce(h.view_path, "/${k}_block")
    }
  }

  # Flatten nested hosts.*.volumes for volume / mapping for_each
  volumes = merge([
    for host_key, host in var.hosts : {
      for vol_name, vol in host.volumes : vol_name => {
        size     = vol.size
        host_key = host_key
      }
    }
  ]...)
}

# -------------------------------------------------------------------------
# Own only what we create: view / hosts / volumes / maps
# Provider 3.x: vastdata_block_host + vastdata_block_host_mapping
# -------------------------------------------------------------------------

# One block subsystem (view) per client host
resource "vastdata_view" "windows_block" {
  for_each = var.hosts

  path       = local.host_views[each.key].path
  name       = local.host_views[each.key].name
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

# Volumes under each host's subsystem
resource "vastdata_volume" "this" {
  for_each = local.volumes

  name    = each.key
  size    = each.value.size # bytes
  view_id = vastdata_view.windows_block[each.value.host_key].id
}

# Map each volume to its host
resource "vastdata_block_host_mapping" "this" {
  for_each = local.volumes

  volume_id = vastdata_volume.this[each.key].id
  host_id   = vastdata_block_host.this[each.value.host_key].id
}
