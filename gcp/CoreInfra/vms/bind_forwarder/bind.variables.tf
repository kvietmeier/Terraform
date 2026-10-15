###===================================================================================###
#
#  File:  bind.variables.tf
#  Created By: Karl Vietmeier
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

variable "network_name" {
  description = "VPC network name (for optional DNS firewall rule)"
  type        = string
}

variable "subnet_name" {
  description = "Existing subnetwork name to attach the NIC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR allowed to query BIND (named ACL + optional FW source ranges)"
  type        = string
}

variable "additional_query_cidrs" {
  description = "Extra CIDRs allowed to query BIND"
  type        = list(string)
  default     = []
}

variable "assign_public_ip" {
  description = "Attach ephemeral public IP (usually false — use IAP)"
  type        = bool
  default     = false
}

variable "enable_dns_firewall" {
  description = "Create a VPC firewall rule allowing UDP/TCP 53 to vm_tags from query CIDRs"
  type        = bool
  default     = true
}

###--- Instance

variable "vm_name" {
  description = "GCE instance name / hostname"
  type        = string
  default     = "bind-vast-fwd"
}

variable "machine_type" {
  description = "Machine type — e2-micro is enough for a forwarder"
  type        = string
  default     = "e2-micro"
}

variable "bootdisk_size" {
  description = "Boot disk size in GiB"
  type        = number
  default     = 20
}

variable "os_image" {
  description = "Boot image (Ubuntu — matches shared cloud-init packages)"
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
}

variable "ssh_user" {
  description = "SSH username written into instance metadata"
  type        = string
  default     = "karlv"
}

variable "ssh_key_file" {
  description = "Path to SSH public key file (multi-key OK)"
  type        = string
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
  description = "Network tags (DNS FW targets these)"
  type        = list(string)
  default     = ["bind-vast-forwarder"]
}

variable "labels" {
  description = "GCE labels (vast-client / role merged in locals)"
  type        = map(string)
  default     = {}
}

###--- BIND / VAST DNS (day-2 knobs — set after cluster is up)

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
