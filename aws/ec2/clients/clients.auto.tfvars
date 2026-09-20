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
security_group_ids = ["sg-030dad04c3ef5f05b"]

ssh_key_name         = "karlv-aws_cloudkey"
ssh_user             = "labuser"
ssh_private_key_path = "$HOME/.ssh/admin_keys/karlv-aws_cloudkey.pem"
cloudinit_configfile = "../../../scripts/cloud-init/cloud-init-universal.yaml"

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
  "voc-client01" = { machine_type = "m6i.2xlarge", bootdisk_size = 256, os_type = "ubuntu" }
  "voc-client02" = { machine_type = "m6i.2xlarge", bootdisk_size = 256, os_type = "ubuntu" }
  "voc-client03" = { machine_type = "m6i.2xlarge", bootdisk_size = 256, os_type = "ubuntu" }
}
