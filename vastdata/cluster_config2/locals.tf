###===================================================================================###
# VAST Data – VIP Pools Locals Configuration (v2 provider)
# Computes VIP end IPs, separates protocol and replication pools,
# and extracts s3Pool and sharesPool keys.
###===================================================================================###

locals {
  # Compute VIP pools with calculated end_ip
  vip_pools = {
    for key, pool in var.vip_pools : key => merge(
      pool,
      {
        end_ip = format(
          "%s%d",
          regex("^([0-9]+\\.[0-9]+\\.[0-9]+\\.)[0-9]+$", pool.start_ip)[0],
          tonumber(regex("[0-9]+$", pool.start_ip)) + (var.number_of_nodes * var.vips_per_node) - 1
        )
      }
    )
  }

  # Protocols pools
  protocols_pools = {
    for k, v in local.vip_pools : k => v
    if v.role == "PROTOCOLS"
  }

  # Replication pools
  replication_pools = {
    for k, v in local.vip_pools : k => v
    if v.role == "REPLICATION"
  }

  # Extract s3Pool and sharesPool keys
  s3pool_key     = [for k, v in local.protocols_pools : k if v.name == "s3Pool"][0]
  sharespool_key = [for k, v in local.protocols_pools : k if v.name == "sharesPool"][0]

  # Effective number of views
  effective_num_views = var.num_views != null ? var.num_views : var.number_of_nodes

  # Map s3 views to policy ID
  s3_views = {
    for key, view in var.s3_views_config : key => merge(
      view,
      {
        policy_id = vastdata_view_policy.s3_basic_policy.id
      }
    )
  }
}
