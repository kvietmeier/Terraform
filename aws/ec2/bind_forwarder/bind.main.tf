###===================================================================================###
#
#  File:  bind.main.tf
#  Created By: Karl Vietmeier
#
#  Tiny Ubuntu EC2 + cloud-init BIND9 conditional forwarder.
#  Uses an existing SG. Day-2 knobs: vast_zones + vast_dns_ips.
#
###===================================================================================###

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = var.ami_owners

  filter {
    name   = "name"
    values = [var.ami_name_filter]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  query_cidrs = distinct(concat([var.vpc_cidr], var.additional_query_cidrs))

  # Standard IT tags + vast-client (always on for this role)
  instance_tags = merge(
    var.common_tags,
    {
      Name          = var.instance_name
      "vast-client" = "true"
      Role          = "bind-vast-forwarder"
    }
  )

  cloudinit = templatefile("${path.module}/cloud-init-bind.yaml.tftpl", {
    vast_zones     = var.vast_zones
    vast_dns_ips   = var.vast_dns_ips
    query_cidrs    = local.query_cidrs
    cloud_resolver = var.cloud_resolver
  })
}

resource "aws_instance" "bind" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  key_name               = var.ssh_key_name
  vpc_security_group_ids = var.security_group_ids

  # Gzip keeps user_data under the 16 KiB limit
  user_data_base64 = base64gzip(local.cloudinit)

  root_block_device {
    volume_size = var.bootdisk_size
    volume_type = "gp3"
    encrypted   = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags        = local.instance_tags
  volume_tags = merge(var.common_tags, { Name = var.instance_name })
}
