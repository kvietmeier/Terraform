###===============================================================================###
#   Create a Windows VM
# 
#   Still written for Linux
#
#
###===============================================================================###

# Configure the Microsoft Azure Provider
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

resource "azurerm_resource_group" "win_vm" {
  name     = "${var.prefix}-rg"
  location = var.region
}

/*
###--- Setup a cloud-init configuration file - need both parts
# refer to the source yaml file
data "template_file" "system_setup" {
  template = file("./scripts/cloud-init")
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
*/

###===================  Network Configuration ====================###`

# Create a vnet
resource "azurerm_virtual_network" "terranet" {
  name                = "${var.prefix}-network"
  address_space       = var.vnet_cidr
  location            = azurerm_resource_group.win_vm.location
  resource_group_name = azurerm_resource_group.win_vm.name
}

resource "azurerm_subnet" "subnet01" {
  name                 = "subnet01"
  address_prefixes     = var.subnet01_cidr
  resource_group_name  = azurerm_resource_group.win_vm.name
  virtual_network_name = azurerm_virtual_network.terranet.name
}

resource "azurerm_subnet" "subnet02" {
  name                 = "subnet02"
  address_prefixes     = var.subnet02_cidr
  resource_group_name  = azurerm_resource_group.win_vm.name
  virtual_network_name = azurerm_virtual_network.terranet.name
}

resource "azurerm_public_ip" "pip" {
  name                = "${var.prefix}-pip"
  location            = azurerm_resource_group.win_vm.location
  resource_group_name = azurerm_resource_group.win_vm.name
  domain_name_label   = "linuxvm01"
  allocation_method   = "Dynamic"
}

###- Create 2 NICs, one with a public IP
resource "azurerm_network_interface" "primary" {
  name                = "${var.prefix}-nic1"
  location            = azurerm_resource_group.win_vm.location
  resource_group_name = azurerm_resource_group.win_vm.name
  enable_accelerated_networking = "false"

  ip_configuration {
    name                          = "primary"
    private_ip_address_allocation = "Dynamic"
    primary                       = true
    subnet_id                     = azurerm_subnet.subnet01.id
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_network_interface" "internal" {
  name                = "${var.prefix}-nic2"
  location            = azurerm_resource_group.win_vm.location
  resource_group_name = azurerm_resource_group.win_vm.name
  enable_accelerated_networking = "true"

  ip_configuration {
    name                          = "internal"
    private_ip_address_allocation = "Dynamic"
    primary                       = false
    subnet_id                     = azurerm_subnet.subnet02.id
  }
}


###- Create an NSG allowing SSH from my IP
resource "azurerm_network_security_group" "ssh" {
  name                = "AllowInbound"
  location            = azurerm_resource_group.win_vm.location
  resource_group_name = azurerm_resource_group.win_vm.name
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


resource "azurerm_network_interface_security_group_association" "mapnsg" {
  network_interface_id      = azurerm_network_interface.primary.id
  network_security_group_id = azurerm_network_security_group.ssh.id
}



###===================  VM Configuration Elements ====================###`

###-- Need boot diags for serial console
# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_resource_group.win_vm.name
    }

    byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "diagstorageaccount" {
    name                     = "diag${random_id.randomId.hex}"
    resource_group_name      = azurerm_resource_group.win_vm.name
    location                 = azurerm_resource_group.win_vm.location
    account_tier             = "Standard"
    account_replication_type = "LRS"

}


###- Put it all together and build the VM
resource "azurerm_linux_virtual_machine" "linuxvm01" {
  name                            = "${var.prefix}-vm"
  location                        = azurerm_resource_group.win_vm.location
  resource_group_name             = azurerm_resource_group.win_vm.name
  size                            = "${var.vm_size}"
  disable_password_authentication = true
  network_interface_ids = [
    azurerm_network_interface.primary.id,
    azurerm_network_interface.internal.id,
  ]

  # Reference the cloud-init file rendered earlier
  custom_data    = data.template_cloudinit_config.config.rendered
  
  # Make sure hostname matches public IP DNS name
  computer_name  = "linuxvm01"

  # Admin user
  admin_username = "${var.username}"
  admin_password = "${var.password}"

  admin_ssh_key {
    username     = "${var.username}"
    public_key   = file("./scripts/id_rsa.pub")
  }

  # They changed the offer and sku for 20.04 - careful
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal-daily"
    sku       = "20_04-daily-lts-gen2"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
  
  # For serial console and monitoring
  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.diagstorageaccount.primary_blob_endpoint
  }
  
}

# Enable auto-shutdown
# "Pacific Standard Time"
# 
resource "azurerm_dev_test_global_vm_shutdown_schedule" "autoshutdown" {
  virtual_machine_id  = azurerm_linux_virtual_machine.linuxvm01.id
  location            = azurerm_resource_group.win_vm.location
  enabled             = true

  daily_recurrence_time = "1800"
  timezone              = "Pacific Standard Time"


  notification_settings {
    enabled         = false
   
  }
 }

 output "dns_name" {
   value = "azurerm_public_ip.domain_name_label"
 }