###===================================================================================###
#  File:         tpu_nodes.tfvars
#  Created By:   Karl Vietmeier / VAST Data
#  License:      Licensed under the Apache License, Version 2.0
#                http://www.apache.org/licenses/LICENSE-2.0
#
#  Description:  Configuration variables for TPU node deployment.
#                Includes project/region settings, network configuration,
#                TPU disk/runtime parameters, and client definitions.
#
###===================================================================================###

###===================================================================================###
#   Basic project and region settings
###===================================================================================###
project_id  = "clouddev-itdesk124"
region      = "us-east5"
tpu_region  = "us-east5"
tpu_zone    = "us-east5-a"  # target zone

###===================================================================================###
#-  Adjust zone to target zone
###===================================================================================###
#zone        = "us-central1-a"  # target zone
#zone        = "us-central1-c"  # target zone
#zone        = "us-central1-f"  # target zone
#zone        = "us-central1-b"  # target zone

tpu_name        = "tpu-testing-node"
tpu_description = "TPU Node created via Terraform"
service_account = "terraform-sa@clouddev-itdesk124.iam.gserviceaccount.com"




###===================================================================================###
#   Network Configuration - subnet you are moving to
###===================================================================================###
vpc_name        = "karlv-corevpc"
subnet_name     = "subnet-hub-us-east5-tpu"
tpu_cidr_block  = "172.10.8.0/29"    # Using the specified CIDR block


###===================================================================================###
#   VARIABLES for Disk and TPU VM
###===================================================================================###
tpu_disk_size_gb     = 200                # Overriding the default of 100
tpu_disk_type        = "pd-ssd"           # Keeping the default
tpu_accelerator_type = "v6e-8"             # Using the available type
tpu_runtime          =  "v6e-ubuntu-2404" 
