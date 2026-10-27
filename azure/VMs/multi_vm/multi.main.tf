###===================================================================================###
#
#  File:  multi.main.tf
#  Created By: Karl Vietmeier
#
#  Azure Linux HPC client fleet (NVMe, UltraSSD, PPG). Names: kv-linuxNN or
#  kv-{copper,lead,…}. Shared ssh user: strata.
#
#  One-time Marketplace accept:
#    az vm image terms accept --urn "azure-hpc:azurelinux-hpc:3:latest"
#
###===================================================================================###

data "azurerm_resource_group" "vnet_rg" {
  name = var.existing_network_rg
}

data "azurerm_virtual_network" "vnet" {
  name                = var.existing_vnet_name
  resource_group_name = data.azurerm_resource_group.vnet_rg.name
}

data "azurerm_subnet" "subnet" {
  name                 = var.existing_subnet_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.vnet_rg.name
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "random_id" "sa_id" {
  byte_length = 4
}

resource "azurerm_storage_account" "boot_diag" {
  name                     = "bootdiag${random_id.sa_id.hex}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_proximity_placement_group" "ppg" {
  name                = "${var.vm_name_prefix}ppg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_public_ip" "pip" {
  for_each = toset(local.vm_name_list)

  name                = "${each.key}-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1"]
  domain_name_label   = "${replace(each.key, "_", "-")}-${random_id.sa_id.hex}"
}

resource "azurerm_network_interface" "nic" {
  for_each = toset(local.vm_name_list)

  name                = "${each.key}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip[each.key].id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  for_each = toset(local.vm_name_list)

  name                = each.key
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.vm_size
  admin_username      = local.admin_username

  disk_controller_type         = var.disk_ctlr
  proximity_placement_group_id = azurerm_proximity_placement_group.ppg.id
  zone                         = "1"

  secure_boot_enabled = var.secure_boot_enabled
  vtpm_enabled        = var.vtpm_enabled

  plan {
    name      = var.image_sku
    product   = var.image_offer
    publisher = var.image_publisher
  }

  network_interface_ids = [
    azurerm_network_interface.nic[each.key].id,
  ]

  additional_capabilities {
    ultra_ssd_enabled = true
  }

  admin_ssh_key {
    username   = local.admin_username
    public_key = file(var.ssh_key_path)
  }

  os_disk {
    caching              = var.os_disk_caching
    storage_account_type = var.os_disk_storage_type
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.boot_diag.primary_blob_endpoint
  }

  custom_data = base64encode(file(local.cloudinit_path))
}

# Flattened UltraSSD disks: vm_name × disk_index
locals {
  data_disks = {
    for pair in setproduct(local.vm_name_list, range(var.data_disk_count_per_vm)) :
    "${pair[0]}-disk${pair[1]}" => {
      vm_name = pair[0]
      lun     = 10 + pair[1]
    }
  }
}

resource "azurerm_managed_disk" "ultra" {
  for_each = local.data_disks

  name                 = each.key
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "UltraSSD_LRS"
  create_option        = "Empty"
  disk_size_gb         = 256
  zone                 = "1"
}

resource "azurerm_virtual_machine_data_disk_attachment" "attach" {
  for_each = local.data_disks

  managed_disk_id    = azurerm_managed_disk.ultra[each.key].id
  virtual_machine_id = azurerm_linux_virtual_machine.vm[each.value.vm_name].id
  lun                = each.value.lun
  caching            = "None"
}

###--- Outputs

output "vm_names" {
  value       = local.vm_name_list
  description = "Generated VM names"
}

output "vm_public_ips" {
  value       = { for name, pip in azurerm_public_ip.pip : name => pip.ip_address }
  description = "Map of VM name → public IP (for Ansible inventory)"
}

output "vm_private_ips" {
  value       = { for name, nic in azurerm_network_interface.nic : name => nic.private_ip_address }
  description = "Map of VM name → private IP"
}

output "ssh_commands" {
  value = {
    for name, pip in azurerm_public_ip.pip :
    name => format(
      "ssh -i %s %s@%s",
      replace(var.ssh_key_path, ".pub", ""),
      local.admin_username,
      pip.ip_address
    )
  }
  description = "SSH commands per VM"
}
