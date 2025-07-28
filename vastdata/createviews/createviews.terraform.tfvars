###===================================================================================###
#  File:  terraform.tfvars
#  Purpose: Set input variables for the VAST Data vipsnviews Terraform module
#  Author: Karl Vietmeier
###===================================================================================###

# =============================
# VAST Cluster Authentication
# =============================
vast_username                = "admin"
vast_password                = "N0mad1c!"
vast_host                    = "vms"
vast_port                    = "443"
vast_skip_ssl_verify         = true
vast_version_validation_mode = "warn"

# =============================
# Existing VIP Pool Name
# =============================
vip_pool_existing           = "protocolsPool"

# =============================
# VIP Pool Permissions
# =============================
vippool_permission_mode     = "RW"

# =============================
# View Policy Configuration
# =============================
policy_name                 = "vpolicy-nfs"
view_policy_flavor          = "MIXED_LAST_WINS"
use_auth_provider           = false
auth_source                 = "RPC_AND_PROVIDERS"
access_flavor               = "ALL"  # Allowed - NFS, SMB, or ALL

# =============================
# View Creation Configuration
# =============================
num_views                   = "8"
path_name                   = "nfs"

# =============================
# Protocol Access Lists
# =============================
nfs_no_squash               = ["0.0.0.0/0"]
nfs_read_write              = ["*"]
nfs_read_only               = []

smb_read_write              = []
smb_read_only               = []


