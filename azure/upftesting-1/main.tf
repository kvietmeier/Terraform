###===================================================================================###
#  File:  main.tf
#  Created By: Karl Vietmeier
#
#  Terraform Template Code
#  Purpose: Create multiple VMs each with 2 NICs for dev/test activities
# 
#  Files in Module:
#    main.tf
#    variables.tf
#    variables.tfvars
#
#  Usage:
#  terraform apply --auto-approve -var-file=".\variables.tfvars"
#  terraform destroy --auto-approve -var-file=".\variables.tfvars"
#
###===================================================================================###

###===============================#===================================================###
###--- Configure the Azure Provider
###===================================================================================###
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


###===================================================================================###
#     Start creating infrastructure resources
###===================================================================================###

# Create a resource group
resource "azurerm_resource_group" "upf_rg" {
  location = var.region
  name     = "${var.resource_prefix}-rg"
}

# Create a Proximity Placement Group
resource "azurerm_proximity_placement_group" "proxplace_grp" {
  location            = azurerm_resource_group.upf_rg.location
  resource_group_name = azurerm_resource_group.upf_rg.name
  name                = "ProximityPlacementGroup"
}

# Enable auto-shutdown
# VM ID is a little tricky to sort out.
resource "azurerm_dev_test_global_vm_shutdown_schedule" "autoshutdown" {
  location              = azurerm_resource_group.upf_rg.location
  count                 = length(azurerm_linux_virtual_machine.vms.*.id)
  virtual_machine_id    = azurerm_linux_virtual_machine.vms[count.index].id
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

# Create the vnet
resource "azurerm_virtual_network" "vnet" {
  location             = azurerm_resource_group.upf_rg.location
  resource_group_name  = azurerm_resource_group.upf_rg.name
  name                 = "${var.resource_prefix}-network"
  address_space        = var.vnet_cidr
}

# 2 Subnets - one for each NIC
resource "azurerm_subnet" "subnets" {
  resource_group_name  = azurerm_resource_group.upf_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  # Create 2 subnets based on number of CIDRs defined in .tfvars
  count                = length(var.subnet_cidrs)
  # Named "subnet01, subnet02" etc....  (keep number under 10)
  name                 = "subnet0${count.index}"
  # Using the address spaces in - subnet_cidrs
  address_prefixes     = [element(var.subnet_cidrs, count.index)]
}

#--- Note - I am using "${var.vm_prefix}-${format("%02d", count.index)}" throughout
#---        to create consistent naming of resources.

# Create the Public IPs
resource "azurerm_public_ip" "public_ips" {
  location            = azurerm_resource_group.upf_rg.location
  resource_group_name = azurerm_resource_group.upf_rg.name
  count               = "${var.node_count}"
  allocation_method   = "Dynamic"
  name                = "${var.vm_prefix}-${format("%02d", count.index)}-PublicIP"
  domain_name_label   = "${var.vm_prefix}-${format("%02d", count.index)}"
}

###- Create 2 NICs - one primary w/PubIP, one internal with SRIOV enabled
resource "azurerm_network_interface" "primary" {
  location                        = azurerm_resource_group.upf_rg.location
  resource_group_name             = azurerm_resource_group.upf_rg.name
  count                           = length(var.subnet2_ips)
  name                            = "${var.vm_prefix}-PrimaryNIC-${format("%02d", count.index)}"
  enable_accelerated_networking   = "false"

  ip_configuration {
    primary                       = true
    name                          = "${var.vm_prefix}-PrimaryCFG-${format("%02d", count.index)}"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = element(azurerm_subnet.subnets[*].id, 0)
    public_ip_address_id          = element(azurerm_public_ip.public_ips[*].id, count.index)
    #private_ip_address_allocation = "Static"
    #private_ip_address            = element(var.subnet1_ips[*].id, count.index)
  }
}

resource "azurerm_network_interface" "internal" {
  location                        = azurerm_resource_group.upf_rg.location
  resource_group_name             = azurerm_resource_group.upf_rg.name
  count                           = length(var.subnet2_ips)
  name                            = "${var.vm_prefix}-InternalNIC-${format("%02d", count.index)}"
  enable_accelerated_networking   = "true"

  ip_configuration {
    primary                       = false
    name                          = "${var.vm_prefix}-InternalCFG-${format("%02d", count.index)}"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = element(azurerm_subnet.subnets[*].id, 1)
    #private_ip_address_allocation = "Static"
    #private_ip_address            = element(var.subnet2_ips[*].id, count.index)
  }
}


###- Create an NSG allowing SSH from my IP
resource "azurerm_network_security_group" "ssh" {
  location                     = azurerm_resource_group.upf_rg.location
  resource_group_name          = azurerm_resource_group.upf_rg.name
  name                         = "AllowInbound"
  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "SSH"
    priority                   = 100
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefixes    = "${var.whitelist_ips}"
    destination_port_range     = "22"
    destination_address_prefix = "*"
  }
  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "RDP"
    priority                   = 101
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefixes    = "${var.whitelist_ips}"
    destination_port_range     = "3389"
    destination_address_prefix = "*"
  }
}

# Map the NSG
resource "azurerm_subnet_network_security_group_association" "mapnsg" {
  subnet_id                 = element(azurerm_subnet.subnets[*].id, 0)
  network_security_group_id = azurerm_network_security_group.ssh.id
}

### Create a vnet peer to the hub vnet
# Syntax is important here -
# 1) Refer to the "source" resources in each peering block by name and the remote vnet resource by its id.
# 2) You match the vnet with its resource group in each peering block

# Spoke-2-Hub Peer
resource "azurerm_virtual_network_peering" "spoke2hub" {
  name                      = "peer-spoke2hub"
  # Source resources by name
  resource_group_name  = azurerm_resource_group.upf_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  # Target vnet by ID
  remote_virtual_network_id = data.azurerm_virtual_network.hub-vnet.id
}

# Hub-2-Spoke Peer
resource "azurerm_virtual_network_peering" "hub2spoke" {
  name                      = "peer-hub2spoke"
  # Source resources by name
  resource_group_name       = data.azurerm_resource_group.hub-rg.name
  virtual_network_name      = data.azurerm_virtual_network.hub-vnet.name
  # Target vnet by ID
  remote_virtual_network_id = azurerm_virtual_network.vnet.id
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
  location              = azurerm_resource_group.upf_rg.location
  resource_group_name   = azurerm_resource_group.upf_rg.name
  count                 = "${var.node_count}"
  name                  = "${var.vm_prefix}-${format("%02d", count.index)}"
  size                  = "${var.vm_size}"
  
  # Attach the 2 NICs
  network_interface_ids = [
    "${element(azurerm_network_interface.primary.*.id, count.index)}",
    "${element(azurerm_network_interface.internal.*.id, count.index)}",
  ]

  # Reference the cloud-init file rendered earlier
  custom_data           = data.template_cloudinit_config.config.rendered
  
  # Make sure hostname matches public IP DNS name
  computer_name         = "${var.vm_prefix}-${format("%02d", count.index)}"

  # User Info
  admin_username        = "${var.username}"
  admin_password        = "${var.password}"
  
  # Password policy
  disable_password_authentication = true

  admin_ssh_key {
    username     = "${var.username}"
    public_key   = file("../scripts/id_rsa.pub")
  }

  # Image and Disk Info
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
  
}

###--- End VM Creation


###--- Outputs

/*
output "public_ip_address" {
  value = "${azurerm_public_ip.public_ips.*.ip_address}"
}
*/

# FQDN of VM primary NICs 
output "public_ip_address" {
  value = "${azurerm_public_ip.public_ips.*.fqdn}"
}