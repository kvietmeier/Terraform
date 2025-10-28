###===================================================================================###
# VAST Data – Cluster Configuration Outputs
#
# Organized outputs for:
# - S3 and shares protocol VIP pools
# - Aggregated VIP pool details
###===================================================================================###


# DNS Info
output "vast_dns_fqdn" {
  value       = "${var.dns_domain_suffix}"
  description = "Cluster DNS Fully Qualified Domain Name"
}

# Usernames
output "vast_usernames" {
  value       = keys(var.users)
  description = "List of configured usernames"
}

output "vast_dns_vip" {
  value       = var.dns_vip
  description = "Cluster DNS VIP Address"
}


output "vip_pool_info" {
  description = "VIP pools summary (dns, start_ip, end_ip, size)"
  value = [
    for k in sort(keys(local.vip_pools)) : {
      name     = local.vip_pools[k].name
      dns_name = try(local.vip_pools[k].dns_name, null)
      start_ip = local.vip_pools[k].start_ip
      end_ip   = local.vip_pools[k].end_ip
      size     = var.number_of_nodes * var.vips_per_node
    }
  ]
}

output "nfs_views_paths" {
  description = "Map of NFS view names to paths"
  value       = { for k, v in var.file_views_config : v.name => v.path }
}

output "s3_views_paths" {
  description = "Map of S3 view names to paths"
  value       = { for k, v in var.s3_views_config : v.name => v.path }
}
