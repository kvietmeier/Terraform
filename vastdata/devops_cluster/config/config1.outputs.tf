###===================================================================================###
# Baseline config outputs
###===================================================================================###

output "protocols_vip_pool" {
  description = "VOC protocolsPool looked up for view-policy binding"
  value = {
    name = data.vastdata_vip_pool.protocols.name
    id   = data.vastdata_vip_pool.protocols.id
  }
}

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

output "vast_dns_vip" {
  description = "Protocol DNS VIP"
  value       = var.dns_vip
}

output "vast_dns_fqdn" {
  description = "Protocol DNS domain suffix"
  value       = var.dns_domain_suffix
}
