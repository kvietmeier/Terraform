###===================================================================================###
#
#  File:  clients.main.tf
#  Created By: Karl Vietmeier
#
#  Purpose: Deploy a pool of identical AWS EC2 client instances (cloud-init,
#           existing key pair, tagging). Scale with num_vm + vm_base_name.
#           For unique per-VM specs, use ../linux_clients_map (map-driven).
#
###===================================================================================###

###===================================================================================###
###                  Start creating infrastructure resources                          ###

# Single AMI lookup for the shared os_type
data "aws_ami" "os" {
  most_recent = true
  owners      = var.os_amis[var.os_type].owners

  filter {
    name   = "name"
    values = [var.os_amis[var.os_type].name_filter]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "vm_instance" {
  for_each = toset(local.vm_names)

  ami                    = data.aws_ami.os.id
  instance_type          = var.machine_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.ssh_key_name
  # AWS user_data max is 16 KiB. Gzip keeps the full embedded bootstrap under that.
  user_data_base64 = base64gzip(local.cloudinit_config)

  root_block_device {
    volume_size = var.bootdisk_size
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
