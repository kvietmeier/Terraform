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
region      = "us-west4"
zone        = "us-west4-a"

###===================================================================================###
#                             Network Configuration
###===================================================================================###

vpc_name     = "karlv-corevpc"
subnet_name  = "subnet-hub-us-west4"

###===================================================================================###
#                              Service Account Configuration
###===================================================================================###

sa_email  = "913067105288-compute@developer.gserviceaccount.com"
sa_scopes = ["cloud-platform"]


# ... Project and Location settings remain the same ...

###===================================================================================###
#                                VM Configuration
###===================================================================================###

vm_name        = "isaac-blackwell-01"
machine_type   = "g4-standard-96"                  # REQUIRED for dual RTX 6000 Blackwell
os_image       = "ubuntu-os-cloud/ubuntu-2404-lts-amd64" # REQUIRED for Robotics/Blackwell
bootdisk_size  = "100"                             # 100GB Boot + 500GB Data Disk
vm_tags        = ["karlv-vms", "isaac-workstation"] # Add tag for your firewall rules


###===================================================================================###
#                            SSH and Cloud-Init Configuration
###===================================================================================###

ssh_user             = "karlv"
ssh_key_file         = "../../../secrets/ssh_keys.txt"
#cloudinit_configfile = "../../scripts/gcp-cloud-init-multiOS.yaml"
