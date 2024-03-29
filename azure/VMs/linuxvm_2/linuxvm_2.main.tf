###===================================================================================###
#   Copyright (C) 2022 Intel Corporation
#   SPDX-License-Identifier: Apache-2.0
###===================================================================================###
#  File:  linuxvm_2.main.tf
#  Created By: Karl Vietmeier
#
#  Terraform Template Code
#  Purpose: Create a single Linux VM
#
#  Files in Module:
#    linuxvm_2.main.tf
#    linuxvm_2.provider.tf
#    linuxvm_2.network.tf
#    linuxvm_2.variables.tf
#    linuxvm_2.tfvars      (in .gitignore)
#    linuxvm_2.tfvars.txt  (scrubbed for github)
#
/* 
  Usage:
  terraform apply --auto-approve -var-file=".\linuxvm_2.variables.tfvars"
  terraform destroy --auto-approve -var-file=".\linuxvm_2.variables.tfvars"
  
  VM Provider - 
  https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine
  https://github.com/hashicorp/terraform-provider-azurerm/tree/main/examples/virtual-machines/linux
  
  cloud-init:
  https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/cloudinit_config
  https://canonical-cloud-init.readthedocs-hosted.com/en/latest/explanation/format.html#mime-multi-part-archive

  
  * Hyperthreading is disabled with a tag (needs to open Support Ticket to enable feature)

*/

###--- Configure the Azure Provider in provider.tf


###===================================================================================###
#     Start creating infrastructure resources                                           #
#                                                                                       #

resource "azurerm_resource_group" "linuxvm_rg" {
  name     = "${var.prefix}-rg"
  location = var.region
}


###--- Setup a cloud-init configuration file - need both parts
# Refer to the source yaml file
data "template_file" "system_setup" {
  template = file(var.cloudinit)
}

# Render a multi-part cloud-init config making use of the file above, and other source files if required
data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  # Main cloud-config configuration file.
  #   Refer to it this way in "os_profile" 
  #   custom_data = data.template_cloudinit_config.config.rendered
  part {
    filename     = "cloud-init.voltdb"
    content_type = "text/cloud-config"
    content      = data.template_file.system_setup.rendered
  }
}


###===================================================================================###
#       VM Configuration - Supporting services                                          #
#                                                                                       #

/* Storage Account:
   * Need boot diags for the serial console which requires a storage account
   * Create an SA for the VM/s so we clean up after and not clutter up an existing SA.    
*/

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.linuxvm_rg.name
  }

  byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "diagstorageaccount" {
  name                     = "diag${random_id.randomId.hex}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  resource_group_name      = azurerm_resource_group.linuxvm_rg.name
  location                 = azurerm_resource_group.linuxvm_rg.location
}

# Enable auto-shutdown
# VM ID is a little tricky to sort out.
resource "azurerm_dev_test_global_vm_shutdown_schedule" "autoshutdown" {
  location              = azurerm_resource_group.linuxvm_rg.location
  virtual_machine_id    = azurerm_linux_virtual_machine.linuxvm01.id
  enabled               = true
  daily_recurrence_time = var.shutdown_time
  timezone              = var.timezone

  notification_settings {
    enabled = false
  }
}


###===================================================================================###
#       Create the VM                                                                   #
#                                                                                       #

resource "azurerm_linux_virtual_machine" "linuxvm01" {
  location                        = azurerm_resource_group.linuxvm_rg.location
  resource_group_name             = azurerm_resource_group.linuxvm_rg.name
  size                            = var.vm_size
  
  # Make sure hostname matches public IP DNS name
  name          = var.vm_name
  computer_name = var.vm_name

  # Attach NICs (created in linuxvm_2.network)
  network_interface_ids = [
    azurerm_network_interface.primary.id,
  ]

  # Reference the cloud-init file rendered earlier
  # for post bringup configuration
  custom_data = data.template_cloudinit_config.config.rendered

  ###--- Admin user
  admin_username = var.username
  admin_password = var.password
  disable_password_authentication = false

  admin_ssh_key {
    username   = var.username
    public_key = file(var.ssh_key)
  }

 ###--- End Admin User
/*  
  dynamic "storage_data_disk" {
    content {
    name = azurerm_managed_disk.lun1.name
    managed_disk_id   = azurerm_managed_disk.lun1.id
    disk_size_gb = azurerm_managed_disk.lun1.disk_size_gb
    caching = "ReadWrite"
    create_option = "Attach"
    lun = 1
    }
  }
   */

  ### Image and OS configuration
  source_image_reference {
    publisher = var.publisher
    offer     = var.offer
    sku       = var.sku
    version   = var.ver
  }

  os_disk {
    name                 = var.vm_name
    caching              = var.caching
    storage_account_type = var.sa_type
  }

  # For serial console and monitoring
  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.diagstorageaccount.primary_blob_endpoint
  }

  tags = {
    # Enable/Disable hyperthreading (requires support ticket to enable feature)
    "platformsettings.host_environment.disablehyperthreading" = "false"
  }

}
###--- End VM Creation

resource "azurerm_managed_disk" "disk1" {
  name                 = "lun17865"
  location             = azurerm_resource_group.linuxvm_rg.location
  resource_group_name  = azurerm_resource_group.linuxvm_rg.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "100"
}

resource "azurerm_virtual_machine_data_disk_attachment" "data1" {
  managed_disk_id    = azurerm_managed_disk.disk1.id
  virtual_machine_id = azurerm_linux_virtual_machine.linuxvm01.id
  lun                = "10"
  caching            = "ReadWrite"
}



###===================================================================================###
#      Outputs                                                                          #
#                                                                                       #

# What is the public IP?
output "dns_name" {
  value = azurerm_public_ip.pip.fqdn
}

### Create some custom outputs - simple cut/paste to SSH
output "ssh_login" {
  value = "ssh ${var.username}@${azurerm_public_ip.pip.fqdn}"
}

output "serial_console" {
  value = "az serial-console connect -g ${azurerm_resource_group.linuxvm_rg.name} -n ${var.vm_name}"
}





###===================================================================================###
# Implement a remote_exec provisioner
/*  This isn't working 
resource "null_resource" GetCPUInfo {
  connection {
    type        = "ssh"
    host        = azurerm_public_ip.pip.fqdn
    user        = var.username
    #password   = var.password
    private_key = file("../../secrets/X1_id_rsa")
    timeout     = 30
  }

  provisioner "remote-exec" {
    inline = [
      "lscpu | grep -i model",
      "sleep 5",
      "cpuid -1 | egrep -i 'vbmi|gfni|vaes|mulqd|bitalg'"
    ]
  }  

  depends_on = [
    azurerm_linux_virtual_machine.linuxvm01
  ]
} 

*/

/* https://github.com/hashicorp/terraform-provider-aws/issues/10977
resource "null_resource" "testinstance" {
  depends_on = [aws_eip.ip-test-env, aws_instance.testinstance]
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = aws_eip.ip-test-env.public_ip
      private_key = file(var.private_key)
      user        = var.ansible_user
      timeout = "30"
    }
    inline     = ["sudo apt-get -qq install python -y"]
    on_failure = continue
  }
}

*/

