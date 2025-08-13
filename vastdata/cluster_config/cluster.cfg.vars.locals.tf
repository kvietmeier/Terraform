/*
===============================================================================
Summary: VIP Pools Locals Configuration

This file defines local variables to manage and process VIP (Virtual IP) pools
for the VAST Data cluster Terraform deployment.

Key Functions:
- Dynamically calculates the `end_ip` for each VIP pool based on the number
  of cluster nodes (`var.number_of_nodes`), extending the IP range accordingly.
- Filters VIP pools by their roles:
    • "PROTOCOLS" pools are grouped in `protocols_pools`.
    • "REPLICATION" pools are grouped in `replication_pools`.
- Identifies and extracts unique keys for the critical protocol pools named
  `s3Pool` and `sharesPool` for use in policies and resource references.

Important Notes:
- This configuration assumes exactly one VIP pool named `s3Pool` and one named
  `sharesPool` exist in `var.vip_pools`.
- If these pools are missing or duplicated, references such as
  `local.s3pool_key` and `local.sharespool_key` will break, causing errors.
- Ensure that `var.vip_pools` is properly defined with unique names for these pools.

This locals block centralizes pool-related computations and filtering to
simplify and standardize references across the Terraform modules.

===============================================================================
*/

locals {

  vip_pools = {
    for key, pool in var.vip_pools : key => merge(
      pool,
      {
        end_ip = format(
          "%s%d",
          regex("^([0-9]+\\.[0-9]+\\.[0-9]+\\.)[0-9]+$", pool.start_ip)[0],
          tonumber(regex("[0-9]+$", pool.start_ip)) + var.number_of_nodes - 1
        )
      }
    )
  }

  protocols_pools = {
    for k, v in local.vip_pools : k => v
    if v.role == "PROTOCOLS"
  }

  s3pool_keys     = [for k, v in local.protocols_pools : k if v.name == "s3Pool"]
  sharespool_keys = [for k, v in local.protocols_pools : k if v.name == "sharesPool"]

  s3pool_key      = local.s3pool_keys[0]
  sharespool_key  = local.sharespool_keys[0]

  replication_pools = {
    for k, v in local.vip_pools : k => v
    if v.role == "REPLICATION"
  }

  s3_views = {
    for key, view in var.s3_views_config : key => merge(
      view,
      {
        policy_id = vastdata_view_policy.s3_basic_policy.id
      }
    )
  }
}
