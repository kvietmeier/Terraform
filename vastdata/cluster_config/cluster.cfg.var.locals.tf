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
###===================================================================================###
# Locals – Dynamic VAST Cluster Configuration (VAST 2.0)
#
# Purpose:
# - Compute derived values for VIP pools, protocols, replication pools, and views.
# - Centralize dynamic configuration logic to avoid hardcoding in resources.
#
# Key Changes for 2.0:
# - VIP pools ip_ranges are flat list(string)
# - Removed vippool_permissions references from locals
# - Maintains dynamic calculation of sharesPool and s3Pool keys
###===================================================================================###

locals {
  # Compute VIP pools with dynamic end IPs
  vip_pools = {
    for key, pool in var.vip_pools : key => merge(
      pool,
      {
        # end_ip no longer used directly; range is computed in main.tf
        computed_range = [
          for i in range(var.number_of_nodes * var.vips_per_node) :
          format(
            "%s%d",
            regex("^([0-9]+\\.[0-9]+\\.[0-9]+\\.)[0-9]+$", pool.start_ip)[0],
            tonumber(regex("[0-9]+$", pool.start_ip)) + i
          )
        ]
      }
    )
  }

  # Protocol VIP pools only
  protocols_pools = {
    for k, v in local.vip_pools : k => v
    if v.role == "PROTOCOLS"
  }

  # Replication VIP pools
  replication_pools = {
    for k, v in local.vip_pools : k => v
    if v.role == "REPLICATION"
  }

  # Extract pool keys dynamically for NFS and S3
  s3pool_keys     = [for k, v in local.protocols_pools : k if v.name == "s3Pool"]
  sharespool_keys = [for k, v in local.protocols_pools : k if v.name == "sharesPool"]

  s3pool_key      = local.s3pool_keys[0]
  sharespool_key  = local.sharespool_keys[0]

  # S3 views merged with policy ID
  s3_views = {
    for key, view in var.s3_views_config : key => merge(
      view,
      {
        policy_id = vastdata_view_policy.s3_basic_policy.id
      }
    )
  }

  # Effective number of NFS views (default = number of nodes)
  effective_num_views = var.num_views != null ? var.num_views : var.number_of_nodes

  # Filter tenants with client IP ranges
  tenants_with_ips = {
    for k, t in var.tenants : k => t
    if length(try(t.client_ip_ranges, [])) > 0
  }
}
