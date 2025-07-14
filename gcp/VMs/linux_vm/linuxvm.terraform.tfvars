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
zone            = "us-west2-c"

# VM Info
vm_name              = "linuxtest01"
machine_type         = "n2-standard-16"
#os_image             = "centos-stream-9-v20241009"
os_image             = "rocky-linux-9-v20250212"
bootdisk_size        = "60"
ssh_key_file         = "../../../secrets/ssh_keys.txt"
cloudinit_configfile = "../../scripts/gcp-cloud-init_dnf-test.yaml"
ssh_user             = "labuser"

# VPC Config - existing
vpc_name        = "default"
subnet_name     = "vocsubnet01-us-west2"

public_ip_name  = "vpntest-public-ip"
private_ip_name = "vpntest-private-ip"
private_ip      = "10.100.1.99"
