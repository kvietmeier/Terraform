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
  description = "VPC ID (informational / future use)"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID to launch the BIND forwarder in"
  type        = string
}

variable "security_group_ids" {
  description = "Existing security group IDs (must allow UDP/TCP 53 + SSH as needed)"
  type        = list(string)
}

variable "vpc_cidr" {
  description = "VPC (or client subnet) CIDR used in named ACL allow-query"
  type        = string
}

variable "additional_query_cidrs" {
  description = "Extra CIDRs allowed to query BIND (named ACL only)"
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
  description = "SSH user (labuser after tweaks; ubuntu also works)"
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
  description = "Standard IT tags (UsedBy/used_by/owned/…). vast-client is always merged on."
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
