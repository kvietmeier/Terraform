###===================================================================================###
#  From:
#  https://medium.com/@yoursshaan2212/terraform-to-provision-multiple-azure-virtual-machines-fab0020b4a6e
#
#  Files:
#    MultiLinuxVMs.tf
#       Main configuration file
#    MultiLinuxVMs-vars.tf
#       Variable declarations
#    MultiLinuxVMs-vars.tfvars (not included in GitHub repo)
#       Variable assignments
#
#    Create multiple VMs
#   
#  Usage:
#  terraform apply -var-file=".\MultiLinuxVM-vars.tfvars"
#  terraform destroy -var-file=".\MultiLinuxVM-vars.tfvars"
#
#   ToDo:
#       * Peer to existing vnet
#       * Cloudinit file
#       * SSH Keys
#       * 2 NICs, one with SRIOV
#
###===================================================================================###

###===================================================================================###
###--- Configure the Azure Provider
###===================================================================================###
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
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

# Create a resource group
resource "azurerm_resource_group" "multivm-rg" {
    name     = "${var.resource_prefix}-resources"
    location = var.region
}

# Create a Proximity Placement Group
resource "azurerm_proximity_placement_group" "proxplace_grp" {
    name                = "ProximityPlacementGroup"
    location = var.region
    resource_group_name = azurerm_resource_group.multivm-rg.name
}

###--- Setup a cloud-init configuration file - need both parts
# refer to the source yaml file
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

###===================================================================================###
###    Networking Section
###===================================================================================###

# Create the virtual network
resource "azurerm_virtual_network" "multivm-vnet" {
    name                = "${var.resource_prefix}-vnet"
    resource_group_name = azurerm_resource_group.multivm-rg.name
    location            = var.region
    address_space       = var.node_address_space
}

# Create a subnet within the virtual network
resource "azurerm_subnet" "multivm-subnet" {
    name                 = "${var.resource_prefix}-subnet"
    resource_group_name  = azurerm_resource_group.multivm-rg.name
    virtual_network_name = azurerm_virtual_network.multivm-vnet.name
    address_prefixes     = [element(var.node_address_prefix, 0)]
}

# Create the Public IPs
resource "azurerm_public_ip" "public_ip" {
    count               = var.node_count
    name                = "${var.vm_prefix}-${format("%02d", count.index)}-PublicIP"
    location            = azurerm_resource_group.multivm-rg.location
    resource_group_name = azurerm_resource_group.multivm-rg.name
    allocation_method   = "Dynamic"
    domain_name_label   = "${var.vm_prefix}-${format("%02d", count.index)}"
}

# Create Network Interfaces and associate the Public IP
resource "azurerm_network_interface" "primary_nic" {
    count               = var.node_count
    name                = "${var.vm_prefix}-${format("%02d", count.index)}-primary-NIC"
    location            = azurerm_resource_group.multivm-rg.location
    resource_group_name = azurerm_resource_group.multivm-rg.name
     
    ip_configuration {
        name = "internal"
        subnet_id = azurerm_subnet.multivm-subnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = element(azurerm_public_ip.public_ip.*.id, count.index)
    }
}

# Create an NSG that restricts access to source IP ranges
resource "azurerm_network_security_group" "public-nsg" {
  name                = "${var.resource_prefix}-NSG"
  location            = azurerm_resource_group.multivm-rg.location
  resource_group_name = azurerm_resource_group.multivm-rg.name

  security_rule {
    access                       = "Allow"
    direction                    = "Inbound"
    name                         = "SSH"
    priority                     = 100
    protocol                     = "Tcp"
    source_port_range            = "*"
    source_address_prefixes      = var.whitelist_ips
    destination_port_range       = "22"
    destination_address_prefix   = "*"
  }
  
  security_rule {
    access                       = "Allow"
    direction                    = "Inbound"
    name                         = "RDP"
    priority                     = 101
    protocol                     = "Tcp"
    source_port_range            = "*"
    source_address_prefixes      = var.whitelist_ips
    destination_port_range       = "3389"
    destination_address_prefix   = "*"
  }
}

# Subnet and NSG association
resource "azurerm_subnet_network_security_group_association" "subnet_nsg_association" {
    subnet_id                 = azurerm_subnet.multivm-subnet.id
    network_security_group_id = azurerm_network_security_group.public-nsg.id
}


###===================================================================================###
###    Create the VM Instances - everything leads up to this step
###===================================================================================###

###-- Need boot diags for serial console
# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_resource_group.multivm-rg.name
    }

    byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "diagstorageaccount" {
    name                     = "diag${random_id.randomId.hex}"
    resource_group_name      = azurerm_resource_group.multivm-rg.name
    location                 = var.region
    account_tier             = "Standard"
    account_replication_type = "LRS"
}

###--- Virtual Machine Creation — Linux
resource "azurerm_virtual_machine" "linux_vms" {
    count                 = var.node_count
    location              = azurerm_resource_group.multivm-rg.location
    resource_group_name   = azurerm_resource_group.multivm-rg.name
    name                  = "${var.resource_prefix}-${format("%02d", count.index)}"
    network_interface_ids = [element(azurerm_network_interface.primary_nic.*.id, count.index)]
    vm_size               = "${var.vm_size}"
    
    proximity_placement_group_id  = azurerm_proximity_placement_group.proxplace_grp.id
    delete_os_disk_on_termination = true
    
    storage_image_reference {
        publisher = "${var.publisher}"
        offer     = "${var.offer}"
        sku       = "${var.sku}"
        version   = "${var.ver}"
    }
    storage_os_disk {
        name              = "osdisk-${var.resource_prefix}-${format("%02d", count.index)}"
        caching           = "${var.caching}"
        create_option     = "${var.create_option}"
        managed_disk_type = "${var.managed_disk_type}"
    }

    os_profile {
        # Reference the cloud-init file rendered earlier
        custom_data    = data.template_cloudinit_config.config.rendered
        # Make sure hostname matches public IP DNS name
        computer_name  = "${var.vm_prefix}-${format("%02d", count.index)}"
        admin_username = "${var.username}"
        admin_password = "${var.password}"
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }

    # For serial console and monitoring
    boot_diagnostics {
        enabled = "true"
        storage_uri = "${azurerm_storage_account.diagstorageaccount.primary_blob_endpoint}"
    }

}
###--- End VM Creation


# Enable auto-shutdown
# VM ID is a little tricky to sort out.
resource "azurerm_dev_test_global_vm_shutdown_schedule" "autoshutdown" {
  count              = length(azurerm_virtual_machine.linux_vms.*.id)
  virtual_machine_id = azurerm_virtual_machine.linux_vms[count.index].id
  location           = azurerm_resource_group.multivm-rg.location
  enabled            = true

  daily_recurrence_time = "1800"
  timezone              = "Pacific Standard Time"

  notification_settings {
    enabled         = false
  }
}