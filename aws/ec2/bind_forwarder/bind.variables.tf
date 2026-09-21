###===================================================================================###
#
#  File:  bind.variables.tf
#  Created By: Karl Vietmeier
#
#  Variable definitions — values from tfvars
#
###===================================================================================###

###--- Provider / account

variable "region" {
  description = "AWS region to deploy resources"
  type        = string
}

###--- Network

variable "vpc_id" {
  description = "VPC ID for the security group and instance"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID to launch the BIND forwarder in"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC (or client subnet) CIDR allowed to query BIND and used in named ACL"
  type        = string
}

variable "additional_query_cidrs" {
  description = "Extra CIDRs allowed to query BIND (SG + named ACL)"
  type        = list(string)
  default     = []
}

variable "ssh_cidr" {
  description = "CIDR allowed for SSH (defaults to vpc_cidr)"
  type        = string
  default     = ""
}

variable "extra_security_group_ids" {
  description = "Optional extra SGs to attach (in addition to the BIND SG)"
  type        = list(string)
  default     = []
}

###--- Instance

variable "instance_name" {
  description = "Name tag / hostname for the forwarder VM"
  type        = string
  default     = "bind-vast-fwd"
}

variable "instance_type" {
  description = "Instance type — t3.nano/t3.micro is enough for a forwarder"
  type        = string
  default     = "t3.micro"
}

variable "bootdisk_size" {
  description = "Root volume size in GiB"
  type        = number
  default     = 8
}

variable "ssh_key_name" {
  description = "Existing EC2 Key Pair name"
  type        = string
}

variable "ssh_user" {
  description = "SSH user (labuser after lab_bootstrap; ubuntu also works)"
  type        = string
  default     = "labuser"
}

variable "ssh_private_key_path" {
  description = "Local private key path for formatted ssh output"
  type        = string
  default     = "~/.ssh/id_rsa"
}

variable "ami_owners" {
  description = "AMI owners (Canonical default)"
  type        = list(string)
  default     = ["099720109477"]
}

variable "ami_name_filter" {
  description = "AMI name filter"
  type        = string
  default     = "ubuntu/images/hvm-ssd*/ubuntu-noble-24.04-amd64-server-*"
}

variable "common_tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default     = {}
}

###--- BIND / VAST DNS

variable "vast_zones" {
  description = "DNS zones to conditionally forward to VAST (no trailing dot)"
  type        = list(string)
}

variable "vast_dns_ips" {
  description = "VAST DNS VIP(s) that host the zone(s)"
  type        = list(string)
}

variable "cloud_resolver" {
  description = "Default cloud VPC resolver (AWS: 169.254.169.253, GCP: 169.254.169.254)"
  type        = string
  default     = "169.254.169.253"
}
