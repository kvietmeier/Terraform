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
/* 
  Usage:
  terraform apply --auto-approve -var-file=".\linux.vm.variables.tfvars"
  terraform destroy --auto-approve -var-file=".\linux.vm.variables.tfvars"

  https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine
  https://github.com/hashicorp/terraform-provider-azurerm/tree/main/examples/virtual-machines/linux

  * Hyperthreading is disabled with a tag (needs to open Support Ticket to enable feature)


*/
###--- Configure the Azure Provider in provider.tf


###===================================================================================###
#     Start creating infrastructure resources
###===================================================================================###

resource "azurerm_resource_group" "linuxvm_rg" {
  name     = "${var.prefix}-rg"
  location = var.region
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


###===================  VM Configuration Elements ====================###`

### - Storage Account
/* 
 Need boot diags for serial console which requires a storage account
 We will create an SA for the VM so we clean up after and not clutter up
 an existing SA.    
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


###
###--- Put it all together and build the VM
###
resource "azurerm_linux_virtual_machine" "linuxvm01" {
  location                        = azurerm_resource_group.linuxvm_rg.location
  resource_group_name             = azurerm_resource_group.linuxvm_rg.name
  name                            = var.vm_name
  size                            = var.vm_size
  disable_password_authentication = true
  network_interface_ids = [
    azurerm_network_interface.primary.id,
    azurerm_network_interface.internal.id,
  ]

  # Reference the cloud-init file rendered earlier
  custom_data = data.template_cloudinit_config.config.rendered

  # Make sure hostname matches public IP DNS name
  computer_name = var.vm_name

  # Admin user
  admin_username = var.username
  admin_password = var.password

  # I keep my keys in a "global" azure folder - TBD: use Azure Keyvault
  admin_ssh_key {
    username   = var.username
    public_key = file("../../secrets/id_rsa-TestMultiple.pub")
  }

  # They changed the offer and sku for 20.04 - careful
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

  /* # Get some info from VM
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = var.username
      public_key = file("../../secrets/id_rsa-TestMultiple.pub")
    }

    inline = [
      "lscpu | grep -i model",

      "sleep 5",

      "cpuid -1 | egrep -i 'vbmi|gfni|vaes|mulqd|bitalg'"
    ]
  }  
  */



}
###--- End VM Creation


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

###--- Outputs
# What is the public IP?
output "dns_name" {
  value = azurerm_public_ip.pip.fqdn
}