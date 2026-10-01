###===================================================================================###
#
#  File:        block.variables.tfvars
#  Author:      Karl Vietmeier
#
#  Description:
#  Lab values for block objects we own. Shared tenant / VIP pool / policy are
#  names for lookups. Uncomment hosts/volumes to grow incrementally.
#  base_nqn_prefix is the client initiator format (vendor-standard NQN).
#
###===================================================================================###

# Lookups (existing shared infrastructure)
tenant_name       = "default"
vip_pool_name     = "vippool-block"
block_policy_name = "block_default_policy"

# One shared block subsystem for these volumes
view_path       = "/windows_block"
view_name       = "windows_block"
view_protocols  = ["BLOCK"]
view_create_dir = true

# -------------------------------------------------------------------------
# Hosts — one per client. Start with one; uncomment to add later.
# NQN = <base_nqn_prefix>:<hostname>
# Set base_nqn_prefix in private.auto.tfvars (gitignored), not here.
# See private.auto.tfvars.example; vendor-specific values: internal GitLab docs.
# -------------------------------------------------------------------------
hosts = {
  "ws-2019bm-01" = {}
  # "ws-2019bm-02" = {}
  # "ws-2022bm-01" = {}
  # "ws-2022bm-02" = {}
}

# -------------------------------------------------------------------------
# Volumes — two per host. Naming: <osyear>_<hostnum>_volN
# size is bytes (2 TiB = 2199023255552)
# -------------------------------------------------------------------------
volumes = {
  "2019_01_vol1" = {
    size     = 2199023255552
    host_key = "ws-2019bm-01"
  }
  "2019_01_vol2" = {
    size     = 2199023255552
    host_key = "ws-2019bm-01"
  }
  # "2019_02_vol1" = { size = 2199023255552, host_key = "ws-2019bm-02" }
  # "2019_02_vol2" = { size = 2199023255552, host_key = "ws-2019bm-02" }
  # "2022_01_vol1" = { size = 2199023255552, host_key = "ws-2022bm-01" }
  # "2022_01_vol2" = { size = 2199023255552, host_key = "ws-2022bm-01" }
  # "2022_02_vol1" = { size = 2199023255552, host_key = "ws-2022bm-02" }
  # "2022_02_vol2" = { size = 2199023255552, host_key = "ws-2022bm-02" }
}
