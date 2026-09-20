###===================================================================================###
#
#  File:  clients.main.tf
#  Created By: Karl Vietmeier
#
#  Purpose: Deploy multiple AWS EC2 client instances with cloud-init,
#           an existing key pair, and tagging.
#           All inputs are variables — nothing hard-coded here.
#
###===================================================================================###

###===================================================================================###
###                  Start creating infrastructure resources                          ###

locals {
  # Only look up AMIs for os_types actually used by var.vms
  used_os_amis = {
    for os_type, ami in var.os_amis : os_type => ami
    if contains([for vm in var.vms : vm.os_type], os_type)
  }
}

# AMI lookups (one data source per os_type in use)
data "aws_ami" "os" {
  for_each = local.used_os_amis

  most_recent = true
  owners      = each.value.owners

  filter {
    name   = "name"
    values = [each.value.name_filter]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "vm_instance" {
  for_each = var.vms

  ami                    = data.aws_ami.os[each.value.os_type].id
  instance_type          = each.value.machine_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.ssh_key_name
  # AWS user_data max is 16 KiB. Gzip keeps the full embedded bootstrap under that.
  user_data_base64       = base64gzip(local.cloudinit_config)

  root_block_device {
    volume_size = each.value.bootdisk_size
  }

  tags = merge(
    var.common_tags,
    { Name = each.key }
  )

  volume_tags = merge(
    var.common_tags,
    { Name = each.key }
  )
}

