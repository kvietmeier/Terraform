###===================================================================================###
#
#  File:  bind.variables.tf
#  Created By: Karl Vietmeier
#
#  Variable definitions — values from tfvars
#
###===================================================================================###

###--- Project / location

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "zone" {
  description = "GCP zone for the forwarder VM"
  type        = string
}

###--- Network

variable "subnet_name" {
  description = "Existing subnetwork name (or self_link) to attach the NIC"
  type        = string
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

variable "assign_public_ip" {
  description = "Attach an ephemeral public IP (usually false — use IAP/bastion)"
  type        = bool
  default     = false
}

###--- Instance

variable "vm_name" {
  description = "GCE instance name / hostname"
  type        = string
  default     = "bind-vast-fwd"
}

variable "machine_type" {
  description = "Machine type — e2-micro/e2-small is enough for a forwarder"
  type        = string
  default     = "e2-micro"
}

variable "bootdisk_size" {
  description = "Boot disk size in GiB"
  type        = number
  default     = 20
}

variable "os_image" {
  description = "Boot image (Ubuntu preferred — matches shared cloud-init packages)"
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
}

variable "ssh_user" {
  description = "SSH username written into instance metadata"
  type        = string
  default     = "ubuntu"
}

variable "ssh_key_file" {
  description = "Path to SSH public key file"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Local private key path for formatted ssh output"
  type        = string
  default     = "~/.ssh/id_rsa"
}

variable "sa_email" {
  description = "Service account email for the VM"
  type        = string
}

variable "sa_scopes" {
  description = "OAuth scopes for the service account"
  type        = list(string)
  default     = ["cloud-platform"]
}

variable "vm_tags" {
  description = "Network tags (firewall must allow UDP/TCP 53 from clients to these tags)"
  type        = list(string)
  default     = ["bind-vast-forwarder"]
}

variable "labels" {
  description = "GCE labels (vast-client / role merged in locals)"
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
  description = "Default cloud VPC resolver (GCP metadata DNS)"
  type        = string
  default     = "169.254.169.254"
}
