###===================================================================================###
#  File:         multi.tfvars
#  Created By:   Karl Vietmeier / KCV Consulting
#  License:      Licensed under the Apache License, Version 2.0
#                http://www.apache.org/licenses/LICENSE-2.0
#
#  Description:  Variable definitions for multi.main.tf
#                Defines VM map, zone, subnet, and service account info.
#
#  Purpose:      Centralized variable values to simplify deployment.
###===================================================================================###

###===================================================================================###
# Project Configuration
# Basic project and region settings
###===================================================================================###
project_id           = "clouddev-itdesk124"
region               = "us-east1"
zone                 = "us-east1-c"

###===================================================================================###
# Network Configuration (existing VPC/Subnet)
###===================================================================================###
vpc_name             = "karlv-corevpc"
subnet_name          = "subnet-hub-us-east1"


###===================================================================================###
# VM Common Settings
# SSH user, key file, and cloud-init configuration applied to all VMs
###===================================================================================###
ssh_user             = "labuser"
ssh_key_file         = "../../../secrets/ssh_keys.txt"
cloudinit_configfile = "../../scripts/gcp-cloud-init-multiOS.yaml"


###===================================================================================###
# Per-VM Configuration
# Map of VM names to their specs
# ip_octet: last octet of static IP (calculated relative to subnet)
###===================================================================================###
vms = {
  "client01" = {
    machine_type   = "e2-standard-8"
    bootdisk_size  = "100"
    os_image       = "ubuntu-2204-jammy-v20250415"   
    #os_image       = "rocky-linux-9-v20250212"
    ip_octet       = 91 
  }
  "client02" = {
    machine_type   = "e2-standard-8"
    bootdisk_size  = "100"
    os_image       = "ubuntu-2204-jammy-v20250415"   
    #os_image       = "rocky-linux-9-v20250212"
    ip_octet       = 92 
  }
  "client03" = {
    machine_type   = "e2-standard-8"
    bootdisk_size  = "100"
    os_image       = "ubuntu-2204-jammy-v20250415"   
    ip_octet       = 93 
  }
  "client04" = {
    machine_type   = "e2-standard-8"
    bootdisk_size  = "100"
    os_image       = "ubuntu-2204-jammy-v20250415"   
    ip_octet       = 94 
  }
  "client05" = {
    machine_type   = "e2-standard-8"
    bootdisk_size  = "100"
    os_image       = "ubuntu-2204-jammy-v20250415"   
    ip_octet       = 95 
  }
  "client06" = {
    machine_type   = "e2-standard-8"
    bootdisk_size  = "100"
    os_image       = "ubuntu-2204-jammy-v20250415"   
    ip_octet       = 96 
  }
  "client07" = {
    machine_type   = "e2-standard-8"
    bootdisk_size  = "100"
    os_image       = "ubuntu-2204-jammy-v20250415"   
    ip_octet       = 97 
  }
  "client08" = {
    machine_type   = "e2-standard-8"
    bootdisk_size  = "100"
    os_image       = "ubuntu-2204-jammy-v20250415"   
    ip_octet       = 98 
  }
  "client09" = {
    machine_type   = "e2-standard-8"
    bootdisk_size  = "100"
    os_image       = "ubuntu-2204-jammy-v20250415"   
    ip_octet       = 99 
  }
  "client10" = {
    machine_type   = "e2-standard-8"
    bootdisk_size  = "100"
    os_image       = "ubuntu-2204-jammy-v20250415"   
    ip_octet       = 100 
  }
  "client11" = {
    machine_type   = "e2-standard-8"
    bootdisk_size  = "100"
    os_image       = "ubuntu-2204-jammy-v20250415"   
    ip_octet       = 101 
  }
}

service_account = {
  email  = "913067105288-compute@developer.gserviceaccount.com"
  scopes = [
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/monitoring.write",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/bigquery"
  ]
}
