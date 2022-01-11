###===================================================================================###
#  File:  multinic.tf
#  Created By: Karl Vietmeier
#
#  Terraform Template Code
#  Purpose: Create multiple VMs each with 2 NICs.
# 
#  Files in Module:
#    multinic.tf
#    multinicvars.tf
#    multinic.tfvars
#
#  Usage:
#  terraform apply --auto-approve -var-file=".\multinic.tfvars"
#  terraform destroy --auto-approve -var-file=".\multinic.tfvars"
###===================================================================================###

# Configure the Microsoft Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}

provider "azurerm" {
  features {}
}


###===================================================================================###
#     Start creating resources
###===================================================================================###

# Resource Group
resource "azurerm_resource_group" "group" {
  name     = "${var.prefix}-rg"
  location = var.region
}

# Proximity Placement Group
resource "azurerm_proximity_placement_group" "proxplace_grp" {
    name                = "ProximityPlacementGroup"
    location = var.region
    resource_group_name = azurerm_resource_group.group.name
}

###--- Setup a cloud-init configuration file - need both parts
# Refer to the source cloud-config file
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
###--- End cloudinit-config


###===================================================================================###
###    Networking Section
###===================================================================================###

# Vnet
resource "azurerm_virtual_network" "vnet" {
  name                = "test-vnet"
  resource_group_name = azurerm_resource_group.group.name
  location            = azurerm_resource_group.group.location
  address_space       = var.vnet_cidr
}

# 2 Subnets - one for each NIC
resource "azurerm_subnet" "subnets" {
  resource_group_name  = azurerm_resource_group.group.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  # Create 2 subnets
  count = length(var.subnet_cidrs)
  # Named "subnet-1, subnet-2"
  name = "subnet-${count.index}"
  # Using the address spaces in - subnet_prefixes
  address_prefix = element(var.subnet_cidrs, count.index)
}

# Create the Public IPs
resource "azurerm_public_ip" "public_ip" {
    count               = 2
    name                = "${var.vm_prefix}-${format("%02d", count.index)}-PublicIP"
    location            = azurerm_resource_group.group.location
    resource_group_name = azurerm_resource_group.group.name
    allocation_method   = "Dynamic"
    domain_name_label   = "${var.vm_prefix}-${format("%02d", count.index)}"
}

# Create 4 NICs using a count index - a total hack
resource "azurerm_network_interface" "nics" {
  # Create 4 NICs - 
  count               = length(var.static_ips)
  name                = "nic-${count.index}"
  location            = azurerm_resource_group.group.location
  resource_group_name = azurerm_resource_group.group.name
  enable_accelerated_networking = element(var.sriov, count.index)

  ip_configuration {
    name = "config-${count.index}"
    # Need to divide by the number of NICs to get the subnet correct
    private_ip_address_allocation = element(var.ip_alloc, count.index)
    primary = tobool(element(var.nic_labels, count.index))
    subnet_id                     = element(azurerm_subnet.subnets[*].id, count.index % 2)
    # TF doesn't iterate a loop - the vm config will grab the first 2 NICs for the first VM, etc....
    private_ip_address = element(var.static_ips, count.index)
  }
}

# This breaks up the 4 element list (NICs) into 2 chunks.
locals {
  # Grab 2 elements for each iteration of the VM creation
  vm_nics = chunklist(azurerm_network_interface.nics[*].id, 2)
}
###--- End Networking


###===================================================================================###
###    Storage Setup Section
###===================================================================================###

###-- Need boot diags for serial console
# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_resource_group.group.name
    }

    byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "diagstorageaccount" {
    name                     = "diag${random_id.randomId.hex}"
    resource_group_name      = azurerm_resource_group.group.name
    location                 = azurerm_resource_group.group.location
    account_tier             = "Standard"
    account_replication_type = "LRS"
}
###--- End Storage


###===================================================================================###
###    Create the VM Instances - everything leads up to this step
###===================================================================================###

###--- Create the VMs
resource "azurerm_linux_virtual_machine" "vms" {
  count                           = var.node_count
  name                            = "linuxvm-${count.index}"
  size                            = "${var.vm_size}"
  resource_group_name             = azurerm_resource_group.group.name
  location                        = azurerm_resource_group.group.location
  proximity_placement_group_id    = azurerm_proximity_placement_group.proxplace_grp.id

  # Attach NICs
  #vm_nics = chunklist(azurerm_network_interface.nics[*].id, 2)
  network_interface_ids           = element(local.vm_nics, count.index)

  # Reference the cloud-init file rendered earlier
  custom_data           = data.template_cloudinit_config.config.rendered
    
  # Make sure hostname matches public IP DNS name
  computer_name  = "${var.vm_prefix}-${format("%02d", count.index)}"

  # User Info
  admin_username = "${var.username}"
  admin_password = "${var.password}"
  disable_password_authentication = false
    
  
  source_image_reference {
    publisher = "${var.publisher}"
    offer     = "${var.offer}"
    sku       = "${var.sku}"
    version   = "${var.ver}"
  }

  os_disk {
    name                 = "osdisk-${var.vm_prefix}-${format("%02d", count.index)}"
    caching              = "${var.caching}"
    storage_account_type = "${var.sa_type}"
  }

  # For serial console and monitoring
  boot_diagnostics {
    storage_account_uri = "${azurerm_storage_account.diagstorageaccount.primary_blob_endpoint}"
  }

  admin_ssh_key {
  username     = "${var.username}"
  public_key   = file("../scripts/id_rsa.pub")
  }

}

# Enable auto-shutdown
# VM ID is a little tricky to sort out.
resource "azurerm_dev_test_global_vm_shutdown_schedule" "autoshutdown" {
  count              = length(azurerm_linux_virtual_machine.vms.*.id)
  virtual_machine_id = azurerm_linux_virtual_machine.vms[count.index].id
  location           = azurerm_resource_group.group.location
  enabled            = true

  daily_recurrence_time = "1800"
  timezone              = "Pacific Standard Time"

  notification_settings {
    enabled         = false
  }
}

###--- End VM Setup