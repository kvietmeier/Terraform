# =========================================================================
# VAST Data Block Storage — our Windows/StarWind lab objects only
# Shared tenant / VIP pool / policy are lookups; never adopt existing hosts
# =========================================================================

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
# Hosts — one per server. Start with 2019bm-01; uncomment to add later.
# NQN default: nqn.2008-08.com.starwind:<hostname>
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
