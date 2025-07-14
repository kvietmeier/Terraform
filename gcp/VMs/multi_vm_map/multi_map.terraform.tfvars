###===================================================================================###
#
#  File:  terraform.tfvars
#  Created By: Karl Vietmeier
#
#  Edit as required
#
###===================================================================================###

# Project Info
project_id           = "clouddev-itdesk124"
region               = "us-east1"
zone                 = "us-east1-c"

# VPC Config - existing
vpc_name             = "karlv-corevpc"
subnet_name          = "subnet-hub-us-east1"

# VM Info
ssh_user             = "labuser"
ssh_key_file         = "../../../secrets/ssh_keys.txt"
cloudinit_configfile = "../../scripts/gcp-cloud-init-multiOS.yaml"

vms = {
  "linux01" = {
    machine_type   = "e2-standard-8"
    bootdisk_size  = "100"
    os_image       = "ubuntu-2204-jammy-v20250415"   
    #os_image       = "rocky-linux-9-v20250212"
    ip_octet       = 91 
  }
  "linux02" = {
    machine_type   = "e2-standard-8"
    bootdisk_size  = "100"
    os_image       = "ubuntu-2204-jammy-v20250415"   
    #os_image       = "rocky-linux-9-v20250212"
    ip_octet       = 92 
  }
  "linux03" = {
    machine_type   = "e2-standard-8"
    bootdisk_size  = "100"
    os_image       = "ubuntu-2204-jammy-v20250415"   
    #os_image       = "rocky-linux-9-v20250212"
    ip_octet       = 93 
  }
  "linux04" = {
    machine_type   = "e2-standard-8"
    bootdisk_size  = "100"
    os_image       = "ubuntu-2204-jammy-v20250415"   
    #os_image       = "rocky-linux-9-v20250212"
    ip_octet       = 94 
  }
  "linux05" = {
    machine_type   = "e2-standard-8"
    bootdisk_size  = "100"
    os_image       = "ubuntu-2204-jammy-v20250415"   
    #os_image       = "rocky-linux-9-v20250212"
    ip_octet       = 95 
  }
  "linux06" = {
    machine_type   = "e2-standard-8"
    bootdisk_size  = "100"
    os_image       = "ubuntu-2204-jammy-v20250415"   
    #os_image       = "rocky-linux-9-v20250212"
    ip_octet       = 96 
  }
  "linux07" = {
    machine_type   = "e2-standard-8"
    bootdisk_size  = "100"
    os_image       = "ubuntu-2204-jammy-v20250415"   
    #os_image       = "rocky-linux-9-v20250212"
    ip_octet       = 97 
  }
  "linux08" = {
    machine_type   = "e2-standard-8"
    bootdisk_size  = "100"
    os_image       = "ubuntu-2204-jammy-v20250415"   
    #os_image       = "rocky-linux-9-v20250212"
    ip_octet       = 98 
  }
  "linux09" = {
    machine_type   = "e2-standard-8"
    bootdisk_size  = "100"
    os_image       = "ubuntu-2204-jammy-v20250415"   
    #os_image       = "rocky-linux-9-v20250212"
    ip_octet       = 99 
  }
  "linux10" = {
    machine_type   = "e2-standard-8"
    bootdisk_size  = "100"
    os_image       = "ubuntu-2204-jammy-v20250415"   
    #os_image       = "rocky-linux-9-v20250212"
    ip_octet       = 100 
  }
  "linux11" = {
    machine_type   = "e2-standard-8"
    bootdisk_size  = "100"
    os_image       = "ubuntu-2204-jammy-v20250415"   
    #os_image       = "rocky-linux-9-v20250212"
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
