###===================================================================================###
# VAST Data – Cluster Configuration Outputs
#
# Organized outputs for:
# - S3 and shares protocol VIP pools
###===================================================================================###



# Usernames
output "vast_usernames" {
  value       = keys(var.users)
  description = "List of configured usernames"
}


output "nfs_views_paths" {
  description = "Map of NFS view names to paths"
  value       = { for k, v in var.file_views_config : v.name => v.path }
}

output "s3_views_paths" {
  description = "Map of S3 view names to paths"
  value       = { for k, v in var.s3_views_config : v.name => v.path }
}
