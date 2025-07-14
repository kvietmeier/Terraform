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
zone                 = "us-west2-a"

# Common VM Info
ssh_user             = "labuser"
ssh_key_file         = "../../../secrets/ssh_keys.txt"
cloudinit_configfile = "../../scripts/gcp-cloud-init_dnf.yaml"

# VPC Config - existing
vpc_name             = "default"
subnet_name          = "infrasubnet01"

#public_ip_name  = "vm3-public-ip"
base_name = "client"

vm_instances = {
  vm1 = {
    machine_type = "e2-medium"
    zone         = "us-west2-a"
    disk_size_gb = 150
    os_image     = "centos-stream-9-v20241009"
    network      = "default"
    subnetwork   = "infrasubnet01"
    #cloudinit    = "../../scripts/gcp-cloud-init_dnf.yaml"
  }
  vm2 = {
    machine_type = "e2-medium"
    zone         = "us-west2-a"
    disk_size_gb = 150
    os_image     = "centos-stream-9-v20241009"
    network      = "default"
    subnetwork   = "infrasubnet01"
    #cloudinit    = "../../scripts/gcp-cloud-init_dnf.yaml"
  }
  vm3 = {
    machine_type = "e2-medium"
    zone         = "us-west2-a"
    disk_size_gb = 150
    os_image     = "centos-stream-9-v20241009"
    network      = "default"
    subnetwork   = "infrasubnet01"
    #cloudinit    = "../../scripts/gcp-cloud-init_dnf.yaml"
  }
}
