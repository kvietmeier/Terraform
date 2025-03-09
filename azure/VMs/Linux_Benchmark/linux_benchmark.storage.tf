###===================================================================================###
#   SPDX-License-Identifier: Apache-2.0
###===================================================================================###
#
#  File:  db_benchmarking.storage.tf
#  Created By: Karl Vietmeier
#
#  Terraform Module Code
#  Purpose:  Creatte storage for the VMs 
# 
###===================================================================================###

/* 

Put Usage Documentation here

*/


###===================================================================================###
#     Start creating infrastructure resources
###===================================================================================###

# Create disk/s
resource "azurerm_managed_disk" "disk1" {
  name                 = "lun17865"
  location             = azurerm_resource_group.multivm_rg.location
  resource_group_name  = azurerm_resource_group.multivm_rg.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "100"
}


/*
# Attach - 
resource "azurerm_virtual_machine_data_disk_attachment" "data1" {
  managed_disk_id    = azurerm_managed_disk.disk1.id
  virtual_machine_id = azurerm_linux_virtual_machine.linuxvm01.id
  lun                = "10"
  caching            = "ReadWrite"
}

*/