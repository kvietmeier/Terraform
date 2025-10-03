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


###===================================================================================###
#-  Adjust zone to target zone
###===================================================================================###
zone        = "us-central1-f"  # target zone

###===================================================================================###
#   Network Configuration - subnet you are moving to
###===================================================================================###
vpc_name    = "karlv-corevpc"
subnet_name = "subnet-hub-us-central1"

###===================================================================================###
#   VM Common Settings
#   SSH user, key file, and service account
###===================================================================================###
ssh_user             = "labuser"
ssh_key_file         = "../../../secrets/ssh_keys.txt"

service_account = {
  email  = "913067105288-compute@developer.gserviceaccount.com"
  scopes = [
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/monitoring.write",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/bigquery"
  ]
}

###===================================================================================###
#   Per-VM Configuration
###===================================================================================###
vms = {
  "client01" = { 
    machine_type  = "n2-standard-32",
    bootdisk_size = 100,
    machine_image = "projects/clouddev-itdesk124/global/machineImages/client01-img-20251003" }
  "client02" = { 
    machine_type  = "n2-standard-32",
    bootdisk_size = 100,
    machine_image = "projects/clouddev-itdesk124/global/machineImages/client02-img-20251003" }
  "client03" = { 
    machine_type  = "n2-standard-32",
    bootdisk_size = 100,
    machine_image = "projects/clouddev-itdesk124/global/machineImages/client03-img-20251003" }
  "client04" = { 
    machine_type  = "n2-standard-32",
    bootdisk_size = 100,
    machine_image = "projects/clouddev-itdesk124/global/machineImages/client04-img-20251003" }
  "client05" = { 
    machine_type  = "n2-standard-32",
    bootdisk_size = 100,
    machine_image = "projects/clouddev-itdesk124/global/machineImages/client05-img-20251003" }
  "client06" = {
    machine_type  = "n2-standard-32",
    bootdisk_size = 100,
    machine_image = "projects/clouddev-itdesk124/global/machineImages/client06-img-20251003" }
  "client07" = {
    machine_type  = "n2-standard-32",
    bootdisk_size = 100,
    machine_image = "projects/clouddev-itdesk124/global/machineImages/client07-img-20251003" }
  "client08" = { 
    machine_type  = "n2-standard-32",
    bootdisk_size = 100,
    machine_image = "projects/clouddev-itdesk124/global/machineImages/client08-img-20251003" }
  "client09" = { 
    machine_type  = "n2-standard-32",
    bootdisk_size = 100,
    machine_image = "projects/clouddev-itdesk124/global/machineImages/client09-img-20251003" }
  "client10" = { 
    machine_type  = "n2-standard-32",
    bootdisk_size = 100,
    machine_image = "projects/clouddev-itdesk124/global/machineImages/client10-img-20251003" }
  "client11" = { 
    machine_type  = "n2-standard-32",
    bootdisk_size = 100,
    machine_image = "projects/clouddev-itdesk124/global/machineImages/client11-img-20251003" }
}
