###===================================================================================###
#
#  File:  multi_map.main.tf
#  Created By: Karl Vietmeier
#
#  Purpose: Deploy unique AWS EC2 client instances from a map (per-VM type,
#           disk, OS). Map keys are short names; Name = vm_name_prefix + key.
#           For an identical scaled pool, use ../multi_vm.
#
###===================================================================================###

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
  for_each = local.vms

  ami                    = data.aws_ami.os[each.value.os_type].id
  instance_type          = each.value.machine_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.ssh_key_name
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
