###===================================================================================###
# Locals – Dynamic VAST Cluster Configuration
#
# Purpose:
# - Compute derived values for VIP pools, protocols, replication pools, and views.
# - Centralize dynamic configuration logic to avoid hardcoding in resources.
#
# Key Functionality:
# - Calculates `end_ip` for VIP pools based on `number_of_nodes` and `vips_per_node`.
# - Separates VIP pools by role (PROTOCOLS vs REPLICATION).
# - Dynamically identifies `sharesPool` and `s3Pool` keys for use in policies.
# - Determines effective number of NFS views (`effective_num_views`).
# - Filters tenants that have valid `client_ip_ranges`.
#
# Usage Notes:
# - All VIP pool names and roles come from `terraform.tfvars`.
# - Adjust `number_of_nodes` or `vips_per_node` in `.tfvars` to scale VIP ranges automatically.
###===================================================================================###
# Dynamic VAST Cluster Configuration (VAST 2.0)
#
# Key Changes for 2.0:
# - VIP pools ip_ranges are flat list(string)
# - Removed vippool_permissions references from locals
# - Maintains dynamic calculation of sharesPool and s3Pool keys
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
