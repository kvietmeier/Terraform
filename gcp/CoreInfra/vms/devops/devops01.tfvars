###===================================================================================###
#
#  File:         devops01.tfvars
#  Created By:   Karl Vietmeier
#
#  Sanitized Terraform variables file.
#  Non-sensitive values are included; sensitive ones are stubbed or referenced externally.
#
#  Edit as required before applying.
#
###===================================================================================###


###===================================================================================###
#                            Project and Location Information
###===================================================================================###

project_id  = "clouddev-itdesk124"
region      = "us-west2"
zone        = "us-west2-a"


###===================================================================================###
#                              Service Account Configuration
###===================================================================================###

sa_email  = "913067105288-compute@developer.gserviceaccount.com"
sa_scopes = ["cloud-platform"]


###===================================================================================###
#                                 VM Configuration
###===================================================================================###

private_ip       = "111.21.0.11"
public_ip_name   = "devops01-public-ip"
private_ip_name  = "devops01-private-ip"
vm_name          = "devops01"
machine_type     = "e2-medium"
os_image         = "centos-stream-9-v20241009"
bootdisk_size    = "200"
vm_tags          = ["karlv-vms", "karlv-linux", "karlv-infra"]


###===================================================================================###
#                            SSH and Cloud-Init Configuration
###===================================================================================###

ssh_user             = "karlv"
ssh_key_file         = "../../../../secrets/karlv_ssh_keys.txt"
cloudinit_configfile = "../../../scripts/gcp-cloud-init-multiOS.yaml"


###===================================================================================###
#                             Network Configuration
###===================================================================================###

vpc_name     = "karlv-corevpc"
subnet_name  = "subnet-hub-us-west2"
