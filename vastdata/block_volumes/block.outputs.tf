###===================================================================================###
#
#  File:        block.outputs.tf
#  Author:      Karl Vietmeier
#
#  Description:
#  Hierarchical map keyed by host: subsystem + initiator + volumes for each client.
#
###===================================================================================###

output "block" {
  description = "Per-initiator map: host → subsystem / nqn / volumes"
  value = {
    for host_key, host in vastdata_block_host.this : host_key => {
      id   = host.id
      name = host.name
      nqn  = host.nqn

      subsystem = {
        name       = vastdata_view.windows_block[host_key].name
        path       = vastdata_view.windows_block[host_key].path
        id         = vastdata_view.windows_block[host_key].id
        target_nqn = try(vastdata_view.windows_block[host_key].nqn, null)
        policy     = data.vastdata_view_policy.selected_view_policy.name
        vip_pool   = data.vastdata_vip_pool.selected_vip_pool.name
      }

      volumes = {
        for vol_name, _ in var.hosts[host_key].volumes : vol_name => {
          id       = vastdata_volume.this[vol_name].id
          name     = vastdata_volume.this[vol_name].name
          size_tib = vastdata_volume.this[vol_name].size / pow(1024, 4)
          view_id  = vastdata_volume.this[vol_name].view_id
          uuid     = try(vastdata_volume.this[vol_name].uuid, null)
          nguid    = try(vastdata_volume.this[vol_name].nguid, null)
        }
      }
    }
  }
}
