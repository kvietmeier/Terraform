###===================================================================================###
#
#  File:  terraform.tfvars
#  Created By: Karl Vietmeier
#
#  This is a "sanitized" version of the terraform.tfvars file that is excluded from the repo. 
#  Any values that aren't sensitive are left defined, amy sensitive values are stubbed out.
#
#  Edit as required
#
###===================================================================================###

region       = "us-east-1"
aws_profile  = "default"

vpc_id      = "vpc-0abcd1234efgh5678"
subnet_id   = "subnet-0abcd1234efgh5678"
subnet_cidr = "10.0.0.0/24"

ssh_key_name         = "labuser-key"
ssh_key_file         = "../../../secrets/ssh_keys.txt"
cloudinit_configfile = "../../scripts/aws-cloud-init-multiOS.yaml"

iam_instance_profile = "LabInstanceProfile"

vms = {
  "client01" = { machine_type="t3.2xlarge", bootdisk_size=100, ip_octet=91, os_type="ubuntu" }
  "client02" = { machine_type="t3.2xlarge", bootdisk_size=100, ip_octet=92, os_type="ubuntu" }
  "client03" = { machine_type="t3.2xlarge", bootdisk_size=100, ip_octet=93, os_type="ubuntu" }
  "client04" = { machine_type="t3.2xlarge", bootdisk_size=100, ip_octet=94, os_type="ubuntu" }
  "client05" = { machine_type="t3.2xlarge", bootdisk_size=100, ip_octet=95, os_type="ubuntu" }
  "client06" = { machine_type="t3.2xlarge", bootdisk_size=100, ip_octet=96, os_type="ubuntu" }
  "client07" = { machine_type="t3.2xlarge", bootdisk_size=100, ip_octet=97, os_type="ubuntu" }
  "client08" = { machine_type="t3.2xlarge", bootdisk_size=100, ip_octet=98, os_type="ubuntu" }
  "client09" = { machine_type="t3.2xlarge", bootdisk_size=100, ip_octet=99, os_type="ubuntu" }
  "client10" = { machine_type="t3.2xlarge", bootdisk_size=100, ip_octet=100, os_type="ubuntu" }
  "client11" = { machine_type="t3.2xlarge", bootdisk_size=100, ip_octet=101, os_type="ubuntu" }
}
