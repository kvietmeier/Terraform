###===================================================================================###
#
#  File:  clients.main.tf
#  Created By: Karl Vietmeier
#
#  Purpose: Deploy multiple AWS EC2 client instances with cloud-init,
#           existing key pair, IAM instance profile, and tagging.
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
  iam_instance_profile   = var.iam_instance_profile
  user_data              = local.cloudinit_config

  root_block_device {
    volume_size = each.value.bootdisk_size
  }

  tags = merge(
    var.common_tags,
    { Name = each.key }
  )
}

# --------------------------------------------------------------------------
# Outputs
# --------------------------------------------------------------------------
output "vm_private_ips" {
  value       = { for name, vm in aws_instance.vm_instance : name => vm.private_ip }
  description = "Map of VM name to private IP"
}

output "vm_ids" {
  value       = { for name, vm in aws_instance.vm_instance : name => vm.id }
  description = "Map of VM name to instance ID"
}
