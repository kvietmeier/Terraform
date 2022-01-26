###===================================================================================###
#  File:  windows-vm.main.tf
#  Created By: Karl Vietmeier
#
#  Terraform Template Code
#  Purpose: Create a single Linux VM
#
#  Files in Module:
#    linux.vm.main.tf
#    linux.vm.variables.tf
#    linux.vm.variables.tfvars
#    linux.vm.variables.tfvars.txt
#
#  Usage:
#  terraform apply --auto-approve -var-file=".\linux.vm.variables.tfvars"
#  terraform destroy --auto-approve -var-file=".\linux.vm.variables.tfvars"
#
###===================================================================================###

###===============================#===================================================###
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
#     Start creating infrastructure resources
###===================================================================================###

resource "azurerm_resource_group" "terrarg" {
  name     = "${var.prefix}-rg"
  location = var.region
}

# Enable auto-shutdown
# VM ID is a little tricky to sort out.
resource "azurerm_dev_test_global_vm_shutdown_schedule" "autoshutdown" {
  location              = azurerm_resource_group.terrarg.location
  virtual_machine_id    = azurerm_linux_virtual_machine.linuxvm01.id
  enabled               = true
  daily_recurrence_time = "${var.shutdown_time}"
  timezone              = "${var.timezone}"

  notification_settings {
    enabled             = false
  }
}


###--- Setup a cloud-init configuration file - need both parts
# refer to the source yaml file
data "template_file" "system_setup" {
  template = file("../secrets/cloud-init")
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

# Create a vnet
resource "azurerm_virtual_network" "terranet" {
  name                = "${var.prefix}-network"
  address_space       = "${var.vnet_cidr}"
  location            = azurerm_resource_group.terrarg.location
  resource_group_name = azurerm_resource_group.terrarg.name
}

resource "azurerm_subnet" "subnet01" {
  name                 = "subnet01"
  address_prefixes     = "${var.subnet01_cidr}"
  resource_group_name  = azurerm_resource_group.terrarg.name
  virtual_network_name = azurerm_virtual_network.terranet.name
}

resource "azurerm_subnet" "subnet02" {
  name                 = "subnet02"
  address_prefixes     = "${var.subnet02_cidr}"
  resource_group_name  = azurerm_resource_group.terrarg.name
  virtual_network_name = azurerm_virtual_network.terranet.name
}

resource "azurerm_public_ip" "pip" {
  name                = "${var.vm_name}-pip"
  domain_name_label   = "${var.vm_name}"
  allocation_method   = "Dynamic"
  location            = azurerm_resource_group.terrarg.location
  resource_group_name = azurerm_resource_group.terrarg.name
}

###- Create 2 NICs, one with a public IP
resource "azurerm_network_interface" "primary" {
  name                          = "${var.vm_name}-nic1"
  enable_accelerated_networking = "false"
  location                      = azurerm_resource_group.terrarg.location
  resource_group_name           = azurerm_resource_group.terrarg.name

  ip_configuration {
    name                          = "primary"
    private_ip_address_allocation = "Dynamic"
    primary                       = true
    subnet_id                     = azurerm_subnet.subnet01.id
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_network_interface" "internal" {
  name                          = "${var.vm_name}-nic2"
  enable_accelerated_networking = "true"
  location                      = azurerm_resource_group.terrarg.location
  resource_group_name           = azurerm_resource_group.terrarg.name

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
  location            = azurerm_resource_group.terrarg.location
  resource_group_name = azurerm_resource_group.terrarg.name
  security_rule {
    access                       = "Allow"
    direction                    = "Inbound"
    name                         = "SSH"
    priority                     = 100
    protocol                     = "Tcp"
    source_port_range            = "*"
    source_address_prefixes      = "${var.whitelist_ips}"
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
    source_address_prefixes      = "${var.whitelist_ips}"
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
        resource_group = azurerm_resource_group.terrarg.name
    }

    byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "diagstorageaccount" {
    name                     = "diag${random_id.randomId.hex}"
    account_tier             = "Standard"
    account_replication_type = "LRS"
    resource_group_name      = azurerm_resource_group.terrarg.name
    location                 = azurerm_resource_group.terrarg.location
}


###- Put it all together and build the VM
resource "azurerm_linux_virtual_machine" "linuxvm01" {
  location                        = azurerm_resource_group.terrarg.location
  resource_group_name             = azurerm_resource_group.terrarg.name
  name                            = "${var.vm_name}"
  size                            = "${var.vm_size}"
  disable_password_authentication = true
  network_interface_ids           = [
    azurerm_network_interface.primary.id,
    azurerm_network_interface.internal.id,
  ]

  # Reference the cloud-init file rendered earlier
  custom_data    = data.template_cloudinit_config.config.rendered
  
  # Make sure hostname matches public IP DNS name
  computer_name  = "${var.vm_name}"

  # Admin user
  admin_username = "${var.username}"
  admin_password = "${var.password}"

  admin_ssh_key {
    username     = "${var.username}"
    public_key   = file("../secrets/id_rsa.pub")
  }

  # They changed the offer and sku for 20.04 - careful
  source_image_reference {
    publisher = "${var.publisher}"
    offer     = "${var.offer}"
    sku       = "${var.sku}"
    version   = "${var.ver}"
  }

  os_disk {
    name                 = "${var.vm_name}"
    caching              = "${var.caching}"
    storage_account_type = "${var.sa_type}"
  }
  
  # For serial console and monitoring
  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.diagstorageaccount.primary_blob_endpoint
  }
  
}
###--- End VM Creation

###--- Outputs
# What is the public IP?
 output "dns_name" {
   value = "${azurerm_public_ip.pip.fqdn}"
 }