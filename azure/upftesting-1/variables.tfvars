###==================================================================================###
#  File:  variables.tfvars
#  Created By: Karl Vietmeier
#  
#  Assign values to the variables defined in variables.tf
#
#
###==================================================================================###

# Basic Information
region          = "West US 2"
resource_prefix = "upftesting"
vm_prefix       = "linux"
shutdown_time   = "1800"
timezone        = "Pacific Standard Time"
Environment     = "UPF Testing"

# OS/VM Info
node_count      = 2
vm_size         = "Standard_D2s_v4"
publisher       = "Canonical"
offer           = "0001-com-ubuntu-server-focal-daily"
sku             = "20_04-daily-lts-gen2"
ver             = "latest"

# OS Disk
caching         = "ReadWrite"
sa_type         = "Standard_LRS"

# User Info
username        = "azureuser"
password        = "Chalc0pyrite"

###===================================================================================###
###  Networking Configuration
###===================================================================================###

# vnet address space
vnet_cidr = ["10.60.0.0/22"]

# Subnet address spaces
subnet_cidrs = [
  "10.60.1.0/24",
  "10.60.2.0/24",
]

# NSG Allow List
whitelist_ips = [
  "47.144.107.198",     # My ISP Address
  "134.134.139.64/27",
  "134.134.137.64/27",
  "192.55.54.32/27",
  "192.55.55.32/27"
]


###---- Not using these right now.
subnet_name = [
  "subnet01",
  "subnet02",
]

# Static IP Allocation
subnet1_ips = [
  "10.60.1.4",
  "10.60.1.5",
]

subnet2_ips = [
  "10.60.2.4",
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


