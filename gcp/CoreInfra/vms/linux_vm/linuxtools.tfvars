###===================================================================================###
#
#  File:  terraform.tfvars
#  Created By: Karl Vietmeier
#
#  This is a "sanitized" version of the terraform.tfvars file that is excluded from the repo. 
#  Any values that aren't sensitive are left defined, amy sensitive values are stubbed out.
#
#  Edit as required
#
###===================================================================================###

# Project Info
project_id      = "clouddev-itdesk124"
region          = "us-west2"
zone            = "us-west2-a"

# VM Info
vm_name         = "linuxtools"
machine_type    = "e2-medium"
os_image        = "centos-stream-9-v20241009"
bootdisk_size   = "200"
ssh_key_file    = "../../../../secrets/ssh_keys.txt"
ssh_user        = "karlv"

# VPC Config - existing
vpc_name        = "default"
subnet_name     = "infrasubnet01"