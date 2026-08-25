# =========================================================================
# VAST Data Block Storage - Master Configuration Values
# =========================================================================

# Lookups (Existing Infrastructure)
tenant_name          = "default"
vip_pool_name        = "my_dedicated_vip_pool"

# Policy Settings
policy_name          = "win-block-policy"
policy_flavor        = "NFS"
policy_auth_source   = "RPC"
policy_read_write    = ["*"]

# View Settings
view_path            = "/windows_block_01"
view_protocols       = ["BLOCK"]
view_create_dir      = true

# Host Settings
host_name            = "win-server-01"
host_nqn             = "nqn.2014-08.org.nvmexpress:uuid:11111111-2222-3333-4444-555555555555"

# Volume Settings
volume_name          = "win_vol1"
volume_size          = "2TB"