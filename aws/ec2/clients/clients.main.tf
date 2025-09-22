###===================================================================================###
# File: multi.aws.tf
# Author: Karl Vietmeier
# Purpose: Flat Terraform config to deploy multiple AWS EC2 instances with cloud-init,
#          static private IPs, SSH access via key pair, IAM role, and tagging.
# License: Apache 2.0
###===================================================================================###

# --------------------------------------------------------------------------
# Terraform / AWS provider
# --------------------------------------------------------------------------
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.27.0"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = var.aws_profile
}

# --------------------------------------------------------------------------
# Key pair for SSH access
# --------------------------------------------------------------------------
resource "aws_key_pair" "labuser" {
  key_name   = var.ssh_key_name
  public_key = file(var.ssh_key_file)
}

# --------------------------------------------------------------------------
# Cloud-init template
# --------------------------------------------------------------------------
data "template_file" "cloudinit" {
  template = local.cloudinit_config
}

# --------------------------------------------------------------------------
# AMI lookups
# --------------------------------------------------------------------------
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_ami" "rocky9" {
  most_recent = true
  owners      = ["679593333241"]
  filter {
    name   = "name"
    values = ["Rocky-9.*-x86_64-GenericCloud-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# --------------------------------------------------------------------------
# Common tags
# --------------------------------------------------------------------------
locals {
  common_tags = {
    Environment = "lab"
    Project     = "vocsales"
    UsedBy      = "vocsales"
  }
}

# --------------------------------------------------------------------------
# EC2 Instances
# --------------------------------------------------------------------------
resource "aws_instance" "vm_instance" {
  for_each       = var.vms

  ami            = lookup(
                     { "ubuntu" = data.aws_ami.ubuntu.id, "rocky" = data.aws_ami.rocky9.id },
                     each.value.os_type,
                     data.aws_ami.ubuntu.id
                   )

  instance_type  = each.value.machine_type
  subnet_id      = var.subnet_id
  private_ip     = cidrhost(var.subnet_cidr, each.value.ip_octet)
  key_name       = aws_key_pair.labuser.key_name
  iam_instance_profile = var.iam_instance_profile
  user_data      = data.template_file.cloudinit.rendered

  root_block_device {
    volume_size = each.value.bootdisk_size
  }

  tags = merge(
    local.common_tags,
    { Name = each.key }
  )
}

# --------------------------------------------------------------------------
# Outputs
# --------------------------------------------------------------------------
output "vm_private_ips" {
  value       = [for vm in aws_instance.vm_instance : vm.private_ip]
  description = "List of private IP addresses of the VMs"
}
