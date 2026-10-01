# =========================================================================
# VAST Data Block Storage - Master Configuration Values
# =========================================================================

# Lookups (Existing Infrastructure)
tenant_name          = "default"
vip_pool_name        = "vippool-block"

# Existing policy — lookup only, never own/modify
block_policy_name    = "block_default_policy"

# View Settings
view_path            = "/windows_block_01"
view_protocols       = ["BLOCK"]
view_create_dir      = true

# Host Settings (StarWind initiator: nqn.2008-08.com.starwind:<hostname>)
host_name            = "starwind_ws2019-01"
host_nqn             = "nqn.2008-08.com.starwind:ws2019-01"

# Volume Settings
volume_name          = "win_vol1"
volume_size          = "2TB"