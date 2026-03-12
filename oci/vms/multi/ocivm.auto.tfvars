###===================================================================================###
#  Terraform Configuration File
#
#  Description : <Brief description of what this file does>
#  Author      : Karl Vietmeier
#
#  License     : Apache 2.0
#
###===================================================================================###

region              = "us-ashburn-1"
availability_domain = "Uocm:US-ASHBURN-AD-1"
compartment_id      = "ocid1.compartment.oc1..aaaaaaa..."

# Networking
subnet_id           = "ocid1.subnet.oc1..aaaaaaa..."

# VM Info
vm_count            = 1
vm_base_name        = "linux"
shape               = "VM.Standard.E4.Flex"
os_image_id         = "ocid1.image.oc1..aaaaaaa..." # Rocky Linux 9 OCID
bootdisk_size       = 150

ssh_user            = "labuser"
ssh_key_file        = "../../../secrets/ssh_keys.txt"
cloudinit_configfile = "../../scripts/gcp-cloud-init_dnf-test.yaml"

