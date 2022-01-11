###===================================================================================###
#  File:  multinic.tfvars
#  Created By: Karl Vietmeier
#
#  Assign variables
#  
#  Files:
#    multinic.tf
#    multinicvars.tf
#    multinic.tfvars
#
#  Usage:
#  terraform apply --auto-approve -var-file=".\multinic.tfvars"
#  terraform destroy --auto-approve -var-file=".\multinic.tfvars"
###===================================================================================###

node_count = 2

# Basic Information
region          = "West US 2"
resource_prefix = "multivm"
vm_prefix       = "upftest"
Environment     = "Test"
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


# vnet address space
vnet_cidr = ["10.60.0.0/22"]


###===================================================================================###
###  NIC Setup - all a bit of a hack at the moment, should probably be 
###  using maps not lists.
###===================================================================================###

# Subnets
subnet_cidrs = [
  "10.60.1.0/24",
  "10.60.2.0/24",
]

subnet_name = [
  "subnet01",
  "subnet02",
]

# for static IPs
nics = [
  "10.60.1.4",
  "10.60.2.4",
  "10.60.1.5",
  "10.60.2.5",
]

# Static IP Allocation
static_ips = [
  "10.60.1.4",
  "10.60.2.4",
  "10.60.1.5",
  "10.60.2.5",
]

nic_labels = [
  "true",
  "false",
  "true",
  "false",
]

ip_alloc = [
  "Static",
  "Static",
  "Static",
  "Static",
]

sriov = [
  "false",
  "true",
  "false",
  "true",
]


