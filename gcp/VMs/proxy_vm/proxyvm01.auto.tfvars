###===================================================================================###
#
#  File:         proxyvm01.tfvars
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
region      = "us-central1"
zone        = "us-central1-b"

###===================================================================================###
#                             Network Configuration
###===================================================================================###

vpc_name     = "karlv-corevpc"
subnet_name  = "subnet-hub-us-central1"

###===================================================================================###
#                              Service Account Configuration
###===================================================================================###

sa_email  = "913067105288-compute@developer.gserviceaccount.com"
sa_scopes = ["cloud-platform"]


###===================================================================================###
#                                 VM Configuration
###===================================================================================###

vm_name          = "proxyvm01"
machine_type     = "e2-medium"
os_image         = "ubuntu-2204-jammy-v20250415"
bootdisk_size    = "200"
vm_tags          = ["karlv-vms", "karlv-linux", "karlv-infra"]
ipforwarding     = false

###===================================================================================###
#                            SSH and Cloud-Init Configuration
###===================================================================================###

ssh_user             = "demo01"
ssh_key_file         = "../../../../personal/secrets/ssh_keys.txt"
cloudinit_configfile = "../../../scripts/cloud-init/gcp-cloud-init-multiOS.yaml"
