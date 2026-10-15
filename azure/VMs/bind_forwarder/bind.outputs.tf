###===================================================================================###
#
#  File:  bind.outputs.tf
#  Created By: Karl Vietmeier
#
###===================================================================================###

output "bind_private_ip" {
  description = "Private IP of the BIND forwarder — point clients here"
  value       = azurerm_network_interface.bind.private_ip_address
}

output "bind_vm_id" {
  description = "Azure VM resource ID"
  value       = azurerm_linux_virtual_machine.bind.id
}

output "resource_group_name" {
  description = "Resource group created for the forwarder"
  value       = azurerm_resource_group.bind.name
}

output "vast_zones" {
  description = "Zones forwarded to VAST"
  value       = var.vast_zones
}

output "vast_dns_ips" {
  description = "VAST DNS target IPs"
  value       = var.vast_dns_ips
}

output "ssh_command" {
  description = "SSH into the forwarder"
  value = format(
    "ssh -i %s %s@%s",
    var.ssh_private_key_path,
    var.admin_username,
    var.assign_public_ip ? azurerm_public_ip.bind[0].ip_address : azurerm_network_interface.bind.private_ip_address
  )
}

output "client_resolv_snippet" {
  description = "systemd-resolved drop-in for test clients (selective VAST domain routing)"
  value       = <<-EOT
    # /etc/systemd/resolved.conf.d/vast-forwarder.conf
    [Resolve]
    DNS=${azurerm_network_interface.bind.private_ip_address}
    Domains=${join(" ", [for z in var.vast_zones : "~${z}"])}
  EOT
}

output "verify_commands" {
  description = "Quick dig checks from the BIND VM or a client"
  value = join("\n", concat(
    [for z in var.vast_zones : "dig @${azurerm_network_interface.bind.private_ip_address} something.${z}"],
    ["dig @${azurerm_network_interface.bind.private_ip_address} google.com"]
  ))
}
