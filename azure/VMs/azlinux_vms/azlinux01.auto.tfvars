###===================================================================================###
# SUMMARY:
#   Configuration Values for the Linux VM deployment.
#   Customize these paths and names for your specific environment.
#
# USAGE:
#   Automatically loaded by Terraform. Do not commit sensitive secrets here.
#
# LICENSE:
#   Copyright 2025 Karl Vietmeier / KCV Consulting
#   SPDX-License-Identifier: Apache-2.0
###===================================================================================###
# --- Target Location & Resource Group ---
resource_group_name = "rg-vastnfs-tf-02"
location            = "Sweden Central"

# --- VM Configuration ---
vm_count                = 2
vm_size                 = "Standard_E2bds_v5"   # NVMe enabled size
data_disk_count_per_vm  = 1
admin_user              = "labuser"

# --- Storage Configuration ---
# Note: disk_controller_type requires provider v3.98+
# If you get an error, remove this, but it is needed for NVMe performance
disk_ctlr = "NVMe"


# --- OS Disk ---
os_disk_caching      = "ReadWrite"
os_disk_storage_type = "Premium_LRS"


# --- AZ Linux Image Configuration ---
image_publisher = "azure-hpc"
image_offer     = "azurelinux-hpc"
image_sku       = "3"
image_version   = "latest"

  # For AZ Linux - Disable Secure Boot to allow unsigned drives to load
security_type = "TrustedLaunch"
secure_boot_enabled = false
vtpm_enabled = true


# --- File Paths (Use Forward Slashes '/' even on Windows) ---
ssh_key_path = "../../../../personal/ssh_keys/ghostw11.id_rsa.pub"

# Using the path found in your PowerShell script 
cloud_init_path = "../../../scripts/cloud-init/azure-cloud-init-multiOS.yaml"


# --- Networking Configuration ---
existing_network_rg  = "rg-karlv-swedencentral"
existing_vnet_name   = "vnet-karlv-swedencentral-00"
existing_subnet_name = "subnet00"
