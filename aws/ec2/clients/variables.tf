###===================================================================================###
#
#  File:  variables.tf
#  Created By: Karl Vietmeier
#
#  Variable definitions with defaults
#
###===================================================================================###

locals {
  common_tags = {
    UsedBy      = "vocsales"
    Project     = "VoC"         # optional extra
    Environment = "lab"     # optional extra
  }
}


variable "region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "aws_profile" {
  description = "AWS CLI profile to use"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "VPC ID to launch EC2 instances in"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID to launch EC2 instances in"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR of subnet for static IP calculation"
  type        = string
}

variable "iam_instance_profile" {
  description = "IAM instance profile name to attach to EC2 instances"
  type        = string
}

variable "ssh_key_name" {
  description = "Name of the AWS Key Pair for SSH access"
  type        = string
}

variable "ssh_key_file" {
  description = "Path to public key file (optional, used to create Key Pair)"
  type        = string
  default     = ""
}

variable "cloudinit_configfile" {
  description = "Path to cloud-init YAML file"
  type        = string
}

variable "vms" {
  description = "Map of VM configurations"
  type = map(object({
    machine_type  = string
    bootdisk_size = number
    ip_octet      = number
    os_type       = string  # 'ubuntu' or 'rocky'
  }))
}

locals {
  ssh_key_content  = file(var.ssh_key_file)
  cloudinit_config = file(var.cloudinit_configfile)
}
