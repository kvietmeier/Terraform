###===================================================================================###
#
#  File:  multi.variables.tf
#  Created By: Karl Vietmeier
#
###===================================================================================###

data "google_compute_subnetwork" "my_subnet" {
  name   = var.subnet_name
  region = var.region
}

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region to deploy resources"
  type        = string
}

variable "zone" {
  description = "The GCP zone to deploy the VMs"
  type        = string
}

variable "service_account" {
  description = "Service account configuration"
  type = object({
    email  = string
    scopes = list(string)
  })
}

variable "vm_count" {
  description = "Number of VMs to create"
  type        = number
  default     = 3
}

variable "vm_base_name" {
  type        = string
  description = "Base name for VM instances (client01, client02, …)"
  default     = "client"
}

variable "user_base_name" {
  type        = string
  description = "Base name for per-VM SSH users (labuser01 on client01, …)"
  default     = "labuser"
}

variable "machine_type" {
  description = "The machine type for the VMs"
  type        = string
  default     = "e2-medium"
}

variable "os_image" {
  description = "OS image or family (e.g. ubuntu-os-cloud/ubuntu-2404-lts-amd64)"
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
}

variable "bootdisk_size" {
  description = "Size of boot disk in GB"
  type        = string
  default     = "50"
}

variable "ssh_key_file" {
  description = "Path to the SSH public key file (multi-key OK)"
  type        = string
}

variable "cloudinit_configfile" {
  description = "Path to the cloud-init yaml"
  type        = string
}

variable "vm_tags" {
  description = "Network tags for firewall targeting"
  type        = list(string)
  default     = []
}

variable "labels" {
  description = "GCE labels (e.g. used=solutions, owned_by=solutions)"
  type        = map(string)
  default     = {}
}

variable "vpc_name" {
  description = "The name of the VPC network (informational)"
  type        = string
  default     = "default"
}

variable "subnet_name" {
  description = "The name of the subnetwork"
  type        = string
  default     = "default"
}

variable "assign_static_ip" {
  description = "If true, assign static private IPs from ip_start_offset; if false, cloud-assign"
  type        = bool
  default     = false
}

variable "ip_start_offset" {
  type        = number
  description = "Host offset for static private IPs when assign_static_ip is true"
  default     = 20
}

locals {
  ssh_key_content  = file(var.ssh_key_file)
  cloudinit_config = file(var.cloudinit_configfile)

  # client01 → labuser01, client02 → labuser02, …
  vms = {
    for i in range(var.vm_count) :
    format("%s%02d", var.vm_base_name, i + 1) => {
      ssh_user = format("%s%02d", var.user_base_name, i + 1)
    }
  }
}
