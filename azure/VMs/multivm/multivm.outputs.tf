###===================================================================================###
#   Copyright (C) 2022 Intel Corporation
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
  value = azurerm_public_ip.public_ips.*.fqdn
}

output "network_interface_private_ip" {
  description = "private ip addresses of the vm nics"
  value       = azurerm_network_interface.internal[*].private_ip_address
}
