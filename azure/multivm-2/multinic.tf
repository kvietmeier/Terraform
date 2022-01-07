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


resource "azurerm_resource_group" "group" {
  name     = "${var.prefix}-resources"
  location = var.region
}


resource "azurerm_virtual_network" "vnet" {
  name                = "test-vnet"
  resource_group_name = azurerm_resource_group.group.name
  location            = azurerm_resource_group.group.location
  address_space       = var.vnet_prefix
}

resource "azurerm_subnet" "subnets" {
  resource_group_name  = azurerm_resource_group.group.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  # Create 2 subnets
  count = length(var.subnet_prefixes)
  # Named "subnet-1, subnet-2"
  name = "subnet-${count.index}"
  # Using the address spaces in - subnet_prefixes
  address_prefix = element(var.subnet_prefixes, count.index)
}

resource "azurerm_network_interface" "nics" {
  # Create 4 NICs - 
  count               = length(var.nics)
  name                = "nic-${count.index}"
  location            = azurerm_resource_group.group.location
  resource_group_name = azurerm_resource_group.group.name

  ip_configuration {
    name = "config-${count.index}"
    # Need to divide by the number of NICs to get the subnet correct
    subnet_id                     = element(azurerm_subnet.subnets[*].id, count.index % 2)
    private_ip_address_allocation = "Static"
    # TF doesn't iterate a loop - the vm config will grab the first 2 NICs for the first VM, etc....
    private_ip_address = element(var.nics, count.index)
  }
}

locals {
  # Grab 2 elements for each iteration of the VM creation
  vm_nics = chunklist(azurerm_network_interface.nics[*].id, 2)
}

resource "azurerm_linux_virtual_machine" "vm" {
  count                           = var.node_count
  name                            = "azurevm-${count.index}"
  resource_group_name             = azurerm_resource_group.group.name
  location                        = azurerm_resource_group.group.location
  size                            = var.vm_size
  admin_username                  = var.username
  admin_password                  = var.password
  disable_password_authentication = false
  network_interface_ids           = element(local.vm_nics, count.index)

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}