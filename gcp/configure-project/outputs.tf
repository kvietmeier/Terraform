output "vpc_network_name" {
  value = module.vpc.network_name
}

output "vpc_network_self_link" {
  value = module.vpc.network_self_link
}

output "subnet_self_links" {
  value = module.vpc.subnet_self_links
}

output "firewall_names" {
  value = try(module.firewalls[0].firewall_names, [])
}

output "dns_private_zone_id" {
  value = try(module.dns_private[0].managed_zone_id, null)
}

output "dns_vast_forwarding_zones" {
  value = try(module.dns_vast_forwarders[0].forwarding_zone_names, {})
}

output "linux_vm_ips" {
  value = {
    for k, m in module.linux_vms : k => {
      public_ip  = m.instance_public_ip
      private_ip = m.instance_private_ip
      zone       = m.zone
    }
  }
}

output "windows_vm_ips" {
  value = {
    for k, m in module.windows_vms : k => {
      public_ip  = m.public_ip
      private_ip = m.private_ip
      zone       = m.zone
    }
  }
}

output "vpn_config_for_azure" {
  description = "Public IPs / ASN to configure on the Azure VPN peer"
  value       = try(module.vpn_gw[0].vpn_config_for_azure, null)
}
