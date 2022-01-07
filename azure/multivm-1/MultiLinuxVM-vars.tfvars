###===================================================================================###
#  From:
#  https://medium.com/@yoursshaan2212/terraform-to-provision-multiple-azure-virtual-machines-fab0020b4a6e
#
#  Files:
#    MultiLinuxVMs.tf
#    MultiLinuxVMs-vars.tf
#    MultiLinuxVMs-vars.tfvars
#
#  Usage:
#  terraform apply -var-file=".\MultiLinuxVM-vars.tfvars"
#  terraform destroy -var-file=".\MultiLinuxVM-vars.tfvars"
#
#  Variable assignments
# 
###===================================================================================###

# Basic Information
region          = "West US 2"
resource_prefix = "multivm"
vm_prefix       = "ubuntu"
Environment     = "Test"
node_count      = 2
vm_size         = "Standard_D2s_v4"

# OS Info
publisher = "Canonical"
offer     = "0001-com-ubuntu-server-focal-daily"
sku       = "20_04-daily-lts-gen2"
ver       = "latest"

# OS Disk
caching = "ReadWrite"
sa_type = "Standard_LRS"

# User Info
username = "azureuser"
password = "Chalc0pyrite"

