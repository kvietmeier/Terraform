###===================================================================================###
#   SPDX-License-Identifier: Apache-2.0
###===================================================================================###
#
#  File:  multivm.outputs.tf
#  Created By: Karl Vietmeier
#
#  Terraform Module Code
#  Purpose: Outputs
# 
###===================================================================================###

/* 
Put Usage Documentation here
*/


/*
output "public_ip_address" {
  value = "${azurerm_public_ip.public_ips.*.ip_address}"
}
*/

# FQDN of VM primary NICs 
output "public_ip_address" {
  value = values(azurerm_public_ip.public_ips)[*].fqdn
}

output "network_interface_private_ip" {
  description = "private ip addresses of the vm nics"
  value       = values(azurerm_network_interface.primary)[*].private_ip_address
}


/* ### Create some custom outputs - simple cut/paste to SSH
output "ssh_login" {
  value = "ssh ${var.username}@${azurerm_public_ip.pip.fqdn}"
}

output "serial_console" {
  value = "az serial-console connect -g ${azurerm_resource_group.linuxvm_rg.name} -n ${var.vm_name}"
}
 */


