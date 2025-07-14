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
region               = "us-west2"
zone                 = "us-west2-c"

# VPC Config - existing
vpc_name             = "default"
subnet_name          = "subnet-hub-us-west2"

# VM Info
vm_count             = "1"
vm_base_name         = "linux"

machine_type         = "n2-standard-16"
#os_image             = "centos-stream-9-v20241009"
os_image             = "rocky-linux-9-v20250212"
bootdisk_size        = "150"
ssh_user             = "labuser"
ssh_key_file         = "../../../secrets/ssh_keys.txt"
cloudinit_configfile = "../../scripts/gcp-cloud-init_dnf-test.yaml"


service_account = {
  email  = "913067105288-compute@developer.gserviceaccount.com"
  scopes = [
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/monitoring.write",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/bigquery"
  ]
}
