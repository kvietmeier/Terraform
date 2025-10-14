###===================================================================================###
#   File:         multi.tfvars
#   Created By:   Karl Vietmeier / KCV Consulting
#   License:      Licensed under the Apache License, Version 2.0
#                 http://www.apache.org/licenses/LICENSE-2.0
#
#   Description:   Variables for 11 clients using machine images
###===================================================================================###

###===================================================================================###
#   Basic project and region settings
###===================================================================================###
project_id  = "clouddev-itdesk124"
region      = "us-east1"
tpu_region  = "us-central1"
tpu_zone    = "us-central1-a"  # target zone

###===================================================================================###
#-  Adjust zone to target zone
###===================================================================================###
#zone        = "us-central1-a"  # target zone
#zone        = "us-central1-c"  # target zone
#zone        = "us-central1-f"  # target zone
#zone        = "us-central1-b"  # target zone

tpu_name        = "my-tpu-node"
tpu_description = "TPU Node created via Terraform"
service_account = "terraform-sa@clouddev-itdesk124.iam.gserviceaccount.com"


###===================================================================================###
#   Network Configuration - subnet you are moving to
###===================================================================================###
vpc_name        = "karlv-corevpc"
subnet_name     = "subnet-hub-us-central1-voc2"
tpu_cidr_block  = "172.11.1.0/29"    # Using the specified CIDR block


###===================================================================================###
#   VARIABLES for Disk and TPU VM
###===================================================================================###
tpu_disk_size_gb     = 200                # Overriding the default of 100
tpu_disk_type        = "pd-ssd"           # Keeping the default
tpu_accelerator_type = "v3-8"             # Using the available type
tpu_runtime          = "tpu-vm-tf-2.13.0"