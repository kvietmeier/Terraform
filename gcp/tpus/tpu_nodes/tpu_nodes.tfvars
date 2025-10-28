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
#  NOTES:
#        * GCP’s TPU API only accepts supported TPU runtime versions, i.e. ones that have
#          a TensorFlow or PyTorch environment (like tpu-vm-tf-* or tpu-vm-pt-*).
#
#        * Custom runtimes (like tpu-ubuntu2204-base) are not supported for TPU VMs.
#          See: https://cloud.google.com/tpu/docs/runtime-versions
#        * Ensure the selected runtime version is compatible with the chosen accelerator type.
#          For example, v5p-8 may not support all TensorFlow versions.
#          Check the latest compatibility matrix in GCP documentation. 
#        * The TPU zone must be in the same region as the TPU runtime version.
#          For example, if using a us-central1 runtime, the TPU zone must be in 
#          us-central1 (e.g., us-central1-a). 
#
###===================================================================================###

###===================================================================================###
#   Basic project and region settings
#   https://cloud.google.com/tpu/docs/regions-zones
#
###===================================================================================###
project_id    = "clouddev-itdesk124"
#region        = "us-east5"
region        = "asia-northeast1"
tpu_region    = "asia-northeast1"
tpu_zone      = "asia-northeast1-b"

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
#   TPU-specific region and zone (can be different from primary region)
#   Subnet needs to be in the region
###===================================================================================###
vpc_name        = "karlv-corevpc"
subnet_name     = "subnet-hub-asia-northeast1-tpu"  # Subnet must already exist
tpu_cidr_block  = "172.10.14.0/29"    # Using the specified CIDR block


###===================================================================================###
#   VARIABLES for Disk and TPU VM
###===================================================================================###
service_account      = "terraform-sa@clouddev-itdesk124.iam.gserviceaccount.com"
tpu_name             = "tpu-test-node"
tpu_description      = "TPU Node/s created via Terraform"
tpu_disk_size_gb     = 200                # Overriding the default of 100
tpu_disk_type        = "pd-ssd"           # Keeping the default
tpu_accelerator_type = "v6e-8"             # Using the available type
tpu_runtime          =  "v6e-ubuntu-2404" 
