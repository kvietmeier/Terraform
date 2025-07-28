###===================================================================================###
#
#  File:  terraform.tfvars
#  Created By: Karl Vietmeier
#
#  This fie should be excuded from GitHub.
#
###===================================================================================###

# Project Info
project_id  = "clouddev-itdesk124"
region      = "us-west2"
zone        = "us-west2-a"


# Service Account/s
sa_email    = "913067105288-compute@developer.gserviceaccount.com"
sa_scopes   = ["cloud-platform"]


# VM Info
vm_name         = "wintest01"
machine_type    = "e2-medium"
os_image        = "windows-server-2022-dc-v20241115"
bootdisk_size   = "300"
vm_tags         = [ "karlv-vms", "karlv-windows", "karlv-infra" ]
windows-startup-script = "../../scripts/windows-startup-config.ps1"


# VPC Config - existing
vpc_name        = "default"
subnet_name     = "infrasubnet01"
public_ip_name  = "wintest-public-ip"
private_ip_name = "wintest-private-ip"

