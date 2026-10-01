# -------------------------------------------------------------------------
# Outputs — cut-paste / screenshot reference for what we created
# -------------------------------------------------------------------------

output "subsystem" {
  description = "Block subsystem view we own (VAST target side)"
  value = {
    name       = vastdata_view.windows_block.name
    path       = vastdata_view.windows_block.path
    id         = vastdata_view.windows_block.id
    target_nqn = try(vastdata_view.windows_block.nqn, null)
    policy     = data.vastdata_view_policy.selected_view_policy.name
    vip_pool   = data.vastdata_vip_pool.selected_vip_pool.name
  }
}

output "hosts" {
  description = "Block hosts (client initiators) we created"
  value = {
    for k, h in vastdata_block_host.this : k => {
      id   = h.id
      name = h.name
      nqn  = h.nqn
    }
  }
}

output "volumes" {
  description = "Volumes we created, with host mapping"
  value = {
    for k, v in vastdata_volume.this : k => {
      id       = v.id
      name     = v.name
      size_tib = v.size / pow(1024, 4)
      host     = var.volumes[k].host_key
      host_id  = vastdata_block_host.this[var.volumes[k].host_key].id
      uuid     = try(v.uuid, null)
      nguid    = try(v.nguid, null)
    }
  }
}

output "summary" {
  description = "Flat cut-paste lines for notes / screenshots"
  value = concat(
    [
      "subsystem: ${vastdata_view.windows_block.name}  path=${vastdata_view.windows_block.path}  id=${vastdata_view.windows_block.id}  target_nqn=${try(vastdata_view.windows_block.nqn, "n/a")}",
      "policy=${data.vastdata_view_policy.selected_view_policy.name}  vip_pool=${data.vastdata_vip_pool.selected_vip_pool.name}",
      "",
      "hosts:",
    ],
    [
      for k, h in vastdata_block_host.this :
      "  ${h.name}  id=${h.id}  nqn=${h.nqn}"
    ],
    [
      "",
      "volumes:",
    ],
    [
      for k, v in vastdata_volume.this :
      "  ${v.name}  id=${v.id}  host=${var.volumes[k].host_key}  size_tib=${v.size / pow(1024, 4)}  uuid=${try(v.uuid, "n/a")}"
    ],
  )
}
