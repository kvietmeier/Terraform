###===================================================================================###
# VAST Data – Cluster Configuration Outputs
#
# Organized outputs for:
# - S3 user credentials (sensitive)
# - S3 and shares protocol VIP pools
# - Aggregated VIP pool details
###===================================================================================###

output "users_keys" {
  value = {
    for k, u in vastdata_user.users : k => {
      id         = u.id
      key_exists = contains(keys(vastdata_user_key.s3keys), k)
    }
  }
}

/*
Disabled for now
#------------------------------------------------------------------------------
# S3 User Keys (Sensitive)
#------------------------------------------------------------------------------
output "s3_access_key" {
  description = "Access key for S3 user s3user1"
  value       = vastdata_user_key.s3key1.access_key
  sensitive   = true
}

output "s3_secret_key_encrypted" {
  description = "Encrypted secret key for S3 user s3user1"
  value       = vastdata_user_key.s3key1.encrypted_secret_key
  sensitive   = true
}


#------------------------------------------------------------------------------
# S3 VIP Pool
#------------------------------------------------------------------------------
output "s3pool_id" {
  description = "Resource ID of the S3 protocol VIP pool (s3Pool)"
  value       = vastdata_vip_pool.protocols[local.s3pool_key].id
}

output "s3pool_details" {
  description = "Full details of the S3 protocol VIP pool (s3Pool)"
  value       = local.protocols_pools[local.s3pool_key]
}


#------------------------------------------------------------------------------
# Shares VIP Pool
#------------------------------------------------------------------------------
output "sharespool_id" {
  description = "Resource ID of the shares protocol VIP pool (sharesPool)"
  value       = vastdata_vip_pool.protocols[local.sharespool_key].id
}

output "sharespool_details" {
  description = "Full details of the shares protocol VIP pool (sharesPool)"
  value       = local.protocols_pools[local.sharespool_key]
}


#------------------------------------------------------------------------------
# All VIP Pools
#------------------------------------------------------------------------------
output "vip_pools_all" {
  description = "Map of all VIP pools (protocols + replication) with calculated end_ip"
  value       = local.vip_pools
}

output "vip_pools_protocols" {
  description = "Map of VIP pools with role = PROTOCOLS"
  value       = local.protocols_pools
} 
*/