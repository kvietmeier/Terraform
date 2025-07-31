###===================================================================================###
# Locals - VIP Pool Selection
#
# This block defines helper local values to identify VIP pools by their roles.
# Specifically, it finds the VIP pool with role "PROTOCOLS" from the input map
# `var.vip_pools` and provides easy access to the corresponding resource instance.
#
# Usage:
# - `local.protocols_pool_key` holds the map key of the PROTOCOLS VIP pool.
# - `local.protocols_pool` references the actual `vastdata_vip_pool` resource instance.
#
# These locals simplify referencing VIP pools dynamically in resources such as
# view policies and views, ensuring correct association based on pool roles.
###===================================================================================###

locals {
  protocols_pool_key = one([
    for k, v in var.vip_pools : k
    if v.role == "PROTOCOLS"
  ])

  protocols_pool = vastdata_vip_pool.vip_pools[local.protocols_pool_key]
}
