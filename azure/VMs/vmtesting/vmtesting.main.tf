###===================================================================================###
#   Copyright (C) 2022 Intel Corporation
#   SPDX-License-Identifier: Apache-2.0
###===================================================================================###
/* 
  File:  multivm.main.tf
  Created By: Karl Vietmeier

  Purpose: Create multiple identical VMs each with 2 NICs for dev/test activities
  ToDo:
    * Use existing NSG
    * Scale Set?
    * Use .pub file for PK instead of actual key
    * Use static IPs for private IP (so we can use Ansible later)
 
  Files in Module:
    multivm.main.tf
    multivm.variables.tf
    multivm.tfvars

  Usage:
  terraform apply --auto-approve
  terraform destroy --auto-approve
  
  If you use a nonstandard tfvars file.
  terraform plan -var-file=".\multivm.tfvars"
  terraform apply --auto-approve -var-file=".\multivm.tfvars"
  terraform destroy --auto-approve -var-file=".\multivm.tfvars"
 
*/
###===================================================================================###

###===================================================================================###
#     Start creating infrastructure resources
###===================================================================================###

# Create a resource group
resource "azurerm_resource_group" "upf_rg" {
  location = var.region
  name     = "${var.resource_prefix}-rg"
}

# Enable auto-shutdown
# VM ID is a little tricky to sort out.
resource "azurerm_dev_test_global_vm_shutdown_schedule" "autoshutdown" {
  location              = azurerm_resource_group.upf_rg.location
  count                 = length(azurerm_linux_virtual_machine.vms.*.id)
  virtual_machine_id    = azurerm_linux_virtual_machine.vms[count.index].id
  enabled               = true
  daily_recurrence_time = var.shutdown_time
  timezone              = var.timezone

  notification_settings {
    enabled = false
  }
}

###--- Setup a cloud-init configuration file - need both parts
# refer to the source yaml file (this file is in .gitignore)
data "template_file" "system_setup" {
  template = file("../scripts/cloud-init")
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
  location            = azurerm_resource_group.upf_rg.location
  resource_group_name = azurerm_resource_group.upf_rg.name
  name                = "VMProximityPlacementGroup"
}


###===================  VM Configuration Elements ====================###`

###-- Need boot diags for serial console
# Generate random text for a unique storage account name
resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.upf_rg.name
  }

  byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "diagstorageaccount" {
  location                 = azurerm_resource_group.upf_rg.location
  resource_group_name      = azurerm_resource_group.upf_rg.name
  name                     = "diag${random_id.randomId.hex}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


###- Put it all together and build the VM
resource "azurerm_linux_virtual_machine" "vms" {
  location            = azurerm_resource_group.upf_rg.location
  resource_group_name = azurerm_resource_group.upf_rg.name
  count               = var.node_count
  name                = "${var.vm_prefix}-${format("%02d", count.index)}"
  size                = var.vm_size

  # Attach the 2 NICs
  network_interface_ids = [
    "${element(azurerm_network_interface.primary.*.id, count.index)}",
    "${element(azurerm_network_interface.internal.*.id, count.index)}",
  ]

  # Reference the cloud-init file rendered earlier
  custom_data = data.template_cloudinit_config.config.rendered

  # Make sure hostname matches public IP DNS name
  computer_name = "${var.vm_prefix}-${format("%02d", count.index)}"

  # Add to proximity placement group
  proximity_placement_group_id = azurerm_proximity_placement_group.vm_prox_grp.id

  # User Info
  admin_username = var.username
  admin_password = var.password

  # Password policy
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.username
    public_key = file(var.ssh_key)
    #public_key   = file("../../secrets/id_rsa-X1Carbon.pub")
  }

  # Image and Disk Info
  source_image_reference {
    publisher = var.publisher
    offer     = var.offer
    sku       = var.sku
    version   = var.ver
  }

  os_disk {
    name                 = "osdisk-${var.vm_prefix}-${format("%02d", count.index)}"
    caching              = var.caching
    storage_account_type = var.sa_type
  }

  # For serial console and monitoring
  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.diagstorageaccount.primary_blob_endpoint
  }

}

###--- End VM Creation

