###==================================================================================###
#  File:  db_benchmarking.tfvars.txt
#  Created By: Karl Vietmeier
#  
#  Assign values to the variables defined in variables.tf
#  
#  This should be in .gitignore
#
###==================================================================================###

# Basic Information
region          = "westus2"
existing-rg     = "karlv-voctesting"
shutdown_time   = "1900"
timezone        = "Pacific Standard Time"
Environment     = "VoC Testing Platform"
cloudinit       = "../scripts/cloud-init-aptbased.azure.yaml"
#resource_prefix = "foo"
#resource_group  = "karlv-voctesting"
#vm_prefix       = "client"

# OS/VM Info
node_count = 2
#vm_size    = "Standard_D2s_v5"
#publisher  = "Canonical"
#offer      = "0001-com-ubuntu-server-focal-daily"
#sku        = "20_04-daily-lts-gen2"
#ver        = "latest"

# OS Disk
caching = "ReadWrite"
sa_type = "Standard_LRS"

# User Info
username = "azadmin"
#ssh_key  = "../../foobar/foo.pub"

# VM Configs - keep it simple for now
# map syntax
vmconfigs = {
  "client01" = {
    name      = "client01"
    size      = "Standard_D2s_v5"
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal-daily"
    sku       = "20_04-daily-lts-gen2"
    ver       = "latest"
    hostnum   = "5"
  },
  "client02" = {
    name      = "client02"
    size      = "Standard_D4ds_v5"
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal-daily"
    sku       = "20_04-daily-lts-gen2"
    ver       = "latest"
    hostnum   = "6"
  },
  "client03" = {
    name      = "client03"
    size      = "Standard_D4ds_v5"
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal-daily"
    sku       = "20_04-daily-lts-gen2"
    ver       = "latest"
    hostnum   = "7"
  },
  "client04" = {
    name      = "client04"
    size      = "Standard_D4ds_v5"
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal-daily"
    sku       = "20_04-daily-lts-gen2"
    ver       = "latest"
    hostnum   = "8"
  }
}



###===================================================================================###
###  Networking Configuration
###===================================================================================###

# Existing vNet and Resource Group for peering
existing-vnet = "vnet-coreinfrahub-karlv"

# vnet address space
vnet_cidr = ["10.###.0.0/22"]

# Subnet info for cidrsubnet()
subnets = {
  default  = 0
  subnet01 = 1
}