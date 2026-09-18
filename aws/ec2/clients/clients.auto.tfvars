###===================================================================================###
#
#  File:  clients.auto.tfvars
#  Created By: Karl Vietmeier
#
#  Values for karlv-i8test-01 clients (us-west-2a)
#
###===================================================================================###

region = "us-west-2"

vpc_id             = "vpc-0537da718b8d70a6e"
subnet_id          = "subnet-004098aa31ced3b4f"
security_group_ids = ["sg-016ab6a15d774a78f"]

ssh_key_name         = "karlv-aws_cloudkey"
cloudinit_configfile = "../../../scripts/cloud-init/cloud-init-universal.yaml"
iam_instance_profile = "LabInstanceProfile"

common_tags = {
  UsedBy      = "vocsales"
  Project     = "VoC"
  Environment = "lab"
  Cluster     = "karlv-i8test-01"
}

# AMI search criteria (only entries matching vms[].os_type are queried)
os_amis = {
  ubuntu = {
    owners      = ["099720109477"] # Canonical
    name_filter = "ubuntu/images/hvm-ssd*/ubuntu-noble-24.04-amd64-server-*"
  }
}

# m6i.2xlarge = 8 vCPU / 32 GiB general purpose; Ubuntu 24.04 + universal cloud-init
vms = {
  "client01" = { machine_type = "m6i.2xlarge", bootdisk_size = 256, os_type = "ubuntu" }
  "client02" = { machine_type = "m6i.2xlarge", bootdisk_size = 256, os_type = "ubuntu" }
  "client03" = { machine_type = "m6i.2xlarge", bootdisk_size = 256, os_type = "ubuntu" }
}
