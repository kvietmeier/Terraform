###===================================================================================###
#
#  File:  bind.main.tf
#  Created By: Karl Vietmeier
#
#  Tiny Ubuntu Azure VM + shared cloud-init BIND9 conditional forwarder.
#  Use when Azure Private DNS / vNet custom DNS cannot be changed.
#  Day-2 knobs: vast_zones + vast_dns_ips.
#
###===================================================================================###

data "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = var.network_resource_group_name
}

data "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = var.network_resource_group_name
}

locals {
  query_cidrs = distinct(concat([var.vnet_cidr], var.additional_query_cidrs))

  tags = merge(
    var.tags,
    {
      "vast-client" = "true"
      Role          = "bind-vast-forwarder"
    }
  )

  # Shared multi-cloud template — edit scripts/cloud-init/, not a per-cloud copy
  cloudinit = templatefile("${path.module}/../../../scripts/cloud-init/cloud-init-bind.yaml.tftpl", {
    vast_zones     = var.vast_zones
    vast_dns_ips   = var.vast_dns_ips
    query_cidrs    = local.query_cidrs
    cloud_resolver = var.cloud_resolver
  })
}

resource "azurerm_resource_group" "bind" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.tags
}

resource "azurerm_public_ip" "bind" {
  count               = var.assign_public_ip ? 1 : 0
  name                = "${var.vm_name}-pip"
  location            = azurerm_resource_group.bind.location
  resource_group_name = azurerm_resource_group.bind.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

resource "azurerm_network_interface" "bind" {
  name                = "${var.vm_name}-nic"
  location            = azurerm_resource_group.bind.location
  resource_group_name = azurerm_resource_group.bind.name
  tags                = local.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.assign_public_ip ? azurerm_public_ip.bind[0].id : null
  }
}

resource "azurerm_network_interface_security_group_association" "bind" {
  count                     = var.nsg_id != null ? 1 : 0
  network_interface_id      = azurerm_network_interface.bind.id
  network_security_group_id = var.nsg_id
}

resource "azurerm_linux_virtual_machine" "bind" {
  name                            = var.vm_name
  location                        = azurerm_resource_group.bind.location
  resource_group_name             = azurerm_resource_group.bind.name
  size                            = var.vm_size
  admin_username                  = var.admin_username
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.bind.id]
  custom_data                     = base64encode(local.cloudinit)
  computer_name                   = var.vm_name
  tags                            = local.tags

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_file)
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-noble"
    sku       = var.ubuntu_sku
    version   = "latest"
  }

  os_disk {
    name                 = "${var.vm_name}-os"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = var.os_disk_size_gb
  }
}
