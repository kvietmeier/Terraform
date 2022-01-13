##
# Output Of Virtual Network ID 
##

output "virtual_network_id_src" {
  value = data.azurerm_virtual_network.existing_source_vnet.id
}

output "subnet_id_src" {
  value = data.azurerm_subnet.src_subnet.id
}

output "virtual_network_id_dtn" {
  value = data.azurerm_virtual_network.existing_destination_vnet.id
}

output "subnet_id_dtn" {
  value = data.azurerm_subnet.dtn_subnet.id
}

#azure
#terraform
#azure-virtual-network
##terraform-provider-azure