###===================================================================================###
#
#  File: winserver2201.terraform.tfvars
#  Created By: Karl Vietmeier
#
#  This file should be excluded from your github repo
#
###===================================================================================###

# Project Info
project_id      = "clouddev-itdesk124"
region          = "us-west2"
zone            = "us-west2-b"

# Service Account/s
sa_email        = "913067105288-compute@developer.gserviceaccount.com"
sa_scopes       = ["cloud-platform"]

# VM Info
private_ip      = "172.20.16.3"
public_ip_name  = "w22server01-public-ip"
private_ip_name = "w22server01-private-ip"
vm_name         = "w22server01"
machine_type    = "c2-standard-4"
os_image        = "windows-server-2022-dc-v20241115"
bootdisk_size   = "400"
vm_tags         = [ "karlv-vms", "karlv-windows", "karlv-infra" ]
windows-sysprep-script = "../../../scripts/windows-sysprep-config.ps1"

# VPC Config - existing
vpc_name        = "karlv-corevpc"
subnet_name     = "subnet-hub-us-west2"
