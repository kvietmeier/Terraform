###===================================================================================###
# SUMMARY:
#   Main Terraform logic for deploying High Performance Linux VMs on Azure.
#   Features: NVMe-enabled VMs, UltraSSD data disks, Proximity Placement Group.
#
# USAGE:
#   Run 'terraform init' then 'terraform apply'.
#
#   Using the Azure Linux Image
#    * Accept Legal Terms (One-Time Only) Before you can deploy this specific Marketplace
#      image programmatically, you must accept the legal terms for your subscription. 
#      
#      Set your contex t to the subscrion you will use and Run this command in 
#      your Azure CLI once:
#      
#      az vm image terms accept --urn "azure-hpc:azurelinux-hpc:3:latest"
#
# LICENSE:
#   Copyright 2025 Karl Vietmeier / KCV Consulting
#   SPDX-License-Identifier: Apache-2.0
###===================================================================================###

# --- Existing Networking Resources ---
# Reference the existing Resource Group for the vNet
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

# --- New Resources ---

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Random ID for storage account uniqueness
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
  name                = "TempPPG-TF"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  #zone                = "1"
}

# --- VM Loop Resources ---

resource "azurerm_public_ip" "pip" {
  count               = var.vm_count
  name                = "vastnfs-pip-${format("%02d", count.index + 1)}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1"]
  domain_name_label   = "vastnfs-tf-${random_id.sa_id.hex}-${count.index + 1}"
}

resource "azurerm_network_interface" "nic" {
  count                         = var.vm_count
  name                          = "vastnfs-nic-${format("%02d", count.index + 1)}"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  #enable_accelerated_networking = true

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip[count.index].id
  }
}

#
###------------- Begion VM Creation ------------###
#
resource "azurerm_linux_virtual_machine" "vm" {
  count               = var.vm_count
  name                = "vastnfs-${format("%02d", count.index + 1)}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.vm_size
  admin_username      = var.admin_user
  
  disk_controller_type = var.disk_ctlr 

  proximity_placement_group_id = azurerm_proximity_placement_group.ppg.id
  zone                         = "1"

  # For AZ Linux - Disable Secure Boot to allow unsigned drives to load
  security_type = var.security_type
  secure_boot_enabled = var.secure_boot_enabled
  vtpm_enabled = var.vtpm_enabled

  plan {
    name      = var.image_sku       # Must match the SKU
    product   = var.image_offer     # Must match the Offer
    publisher = var.image_publisher # Must match the Publisher
  }

  network_interface_ids = [
    azurerm_network_interface.nic[count.index].id,
  ]
  
  # IMPORTANT: Enable UltraSSD and NVMe Controller
  additional_capabilities {
    ultra_ssd_enabled = true
  }
  
  admin_ssh_key {
    username   = var.admin_user
    public_key = file(var.ssh_key_path)
  }

  os_disk {
    # NVMe enabled VMs should ideally use PremiumV2 or Ultra for Data, 
    # but OS disk usually stays Premium_LRS unless strictly Gen2 NVMe required.
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

  custom_data = base64encode(file(var.cloud_init_path))
}

# --- Data Disks (Nested Loop Logic) ---

# Create Disks: (VMs * DisksPerVM)
resource "azurerm_managed_disk" "ultra" {
  count                = var.vm_count * var.data_disk_count_per_vm
  name                 = "datadisk-${floor(count.index / var.data_disk_count_per_vm) + 1}-${count.index % var.data_disk_count_per_vm + 1}"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "UltraSSD_LRS"
  create_option        = "Empty"
  disk_size_gb         = 256
  zone                 = "1"
}

# Attach Disks to VMs
resource "azurerm_virtual_machine_data_disk_attachment" "attach" {
  count              = var.vm_count * var.data_disk_count_per_vm
  managed_disk_id    = azurerm_managed_disk.ultra[count.index].id
  # Math to calculate which VM this disk belongs to:
  virtual_machine_id = azurerm_linux_virtual_machine.vm[floor(count.index / var.data_disk_count_per_vm)].id
  lun                = 10 + (count.index % var.data_disk_count_per_vm)
  caching            = "None" # UltraSSD usually requires caching to be None
}

# --- Outputs ---

output "vm_public_ips" {
  value = {
    for vm, pip in azurerm_public_ip.pip : vm => pip.ip_address
  }
}

output "ssh_commands" {
  value = [
    for ip in azurerm_public_ip.pip : "ssh -i ${replace(var.ssh_key_path, ".pub", "")} labuser@${ip.ip_address}"
  ]
}