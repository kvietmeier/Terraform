###===================================================================================###
#
#  File:  outputs.tf
#  Created By: Karl Vietmeier
#
#  Terraform Module Code
#  Purpose:  Blank Template for extra resources
# 
###===================================================================================###

output "azure_public_ip0" {
  value = azurerm_public_ip.pip0.ip_address
}

output "azure_public_ip1" {
  value = azurerm_public_ip.pip1.ip_address
}