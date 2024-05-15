###===================================================================================###
#   SPDX-License-Identifier: Apache-2.0
###===================================================================================###
/* 
  File:  multivm.main.tf
  Created By: Karl Vietmeier

  Purpose: Create multiple unique VMs each with 2 NICs for dev/test activities
  
  ToDo:
    * Use existing NSG
    * Use static IPs for private IP (so we can use Ansible later)
    * Source a map of VMs so they can be different
 
*/
###===================================================================================###

/* 
  
Usage:
terraform plan -var-file=".\multivm_map.tfvars"
terraform apply --auto-approve -var-file=".\multivm_map.tfvars"
terraform destroy --auto-approve -var-file=".\multivm_map.tfvars"

*/

###===================================================================================###
#                    Start creating infrastructure resources                          ###
###===================================================================================###

# Create a resource group
resource "azurerm_resource_group" "multivm_rg" {
  location = var.region
  name     = "${var.resource_prefix}-rg"
}

###--- Setup a cloud-init configuration file - need both parts
# refer to the source yaml file (this file is in .gitignore)
data "template_file" "system_setup" {
  #template = file("../../secrets/cloud-init")
  template = file(var.cloudinit)
}

# Render a multi-part cloud-init config making use of the file
# above, and other source files if required
data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  # Main cloud-config configuration file.
  # Refer to it this way in "os_profile" 
  # custom_data    = data.template_cloudinit_config.config.rendered
  part {
    filename     = "cloud-init"
    content_type = "text/cloud-config"
    content      = data.template_file.system_setup.rendered
  }
}

###--- Create a Proximity Placement Group
resource "azurerm_proximity_placement_group" "vm_prox_grp" {
  location            = azurerm_resource_group.multivm_rg.location
  resource_group_name = azurerm_resource_group.multivm_rg.name
  name                = "VMProximityPlacementGroup"
}

###--- Create some random stuff
#- Use this for Public IPs
resource "random_id" "pipid" {
  byte_length = 1
}

# Generate random text for unique storage account names
resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.multivm_rg.name
  }

  byte_length = 8
}

###-- Boot diags for serial console
# Create storage account for boot diagnostics
# Needs to be a module!
resource "azurerm_storage_account" "diagstorageaccount" {
  location                 = azurerm_resource_group.multivm_rg.location
  resource_group_name      = azurerm_resource_group.multivm_rg.name
  name                     = "diag${random_id.randomId.hex}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# For added disks/fileshares
resource "azurerm_storage_account" "attachedstorage" {
  location                 = azurerm_resource_group.multivm_rg.location
  resource_group_name      = azurerm_resource_group.multivm_rg.name
  name                     = "attached${random_id.randomId.hex}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}



###===================================================================================###
###                               Build the VMs                                       ###
###===================================================================================###

resource "azurerm_linux_virtual_machine" "vms" {
  location            = azurerm_resource_group.multivm_rg.location
  resource_group_name = azurerm_resource_group.multivm_rg.name
  
  # Loop over VM Map to set name and size
  for_each = var.vmconfigs
  name     = each.value.name
  size     = each.value.size

  # Attach the 2 NICs created earlier
  network_interface_ids = [
    azurerm_network_interface.primary[each.key].id,
    azurerm_network_interface.internal[each.key].id,
  ]

  # Reference the cloud-init file rendered earlier
  custom_data = data.template_cloudinit_config.config.rendered

  # Make sure hostname matches public IP DNS name
  computer_name = each.value.name

  # Add to proximity placement group
  proximity_placement_group_id = azurerm_proximity_placement_group.vm_prox_grp.id

  # User Info
  admin_username = var.username
  admin_password = var.password

  # Password policy - if set to true no password will be set
  disable_password_authentication = false

  admin_ssh_key {
    username   = var.username
    public_key = file(var.ssh_key)
  }

  # Image and Disk Info
  source_image_reference {
    publisher = each.value.publisher
    offer     = each.value.offer
    sku       = each.value.sku
    version   = each.value.ver
  }

  os_disk {
    name                 = "osdisk-${each.value.name}"
    caching              = var.caching
    storage_account_type = var.sa_type
  }

  # For serial console and monitoring
  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.diagstorageaccount.primary_blob_endpoint
  }

}
###--- End VM Creation

###--- Enable auto-shutdown
# VM ID is a little tricky to sort out.
resource "azurerm_dev_test_global_vm_shutdown_schedule" "autoshutdown" {

  for_each = var.vmconfigs

  location              = azurerm_resource_group.multivm_rg.location
  virtual_machine_id    = azurerm_linux_virtual_machine.vms[each.key].id
  enabled               = true
  daily_recurrence_time = var.shutdown_time
  timezone              = var.timezone

  notification_settings {
    enabled = false
  }
}