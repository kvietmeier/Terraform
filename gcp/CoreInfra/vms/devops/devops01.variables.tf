###===================================================================================###
#
#  File:         devops01.variables.tf
#  Created By:   Karl Vietmeier
#
#  Variable definitions with defaults
#
###===================================================================================###


###===================================================================================###
#                            Project and Location Settings
###===================================================================================###

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region to deploy resources"
  type        = string
}

variable "zone" {
  description = "The GCP zone to deploy the VM"
  type        = string
}


###===================================================================================###
#                                  VM Configuration
###===================================================================================###

variable "machine_type" {
  description = "The machine type for the VM"
  type        = string
  default     = "e2-medium"
}

variable "vm_name" {
  description = "Name of the VM instance"
  type        = string
  default     = "my-vm"
}

variable "os_image" {
  description = "OS Image to use"
  type        = string
  default     = "centos-stream-9-v20241009"
}

variable "bootdisk_size" {
  description = "Size of boot disk in GB"
  type        = string
  default     = "40"
}


###===================================================================================###
#                              Service Account Settings
###===================================================================================###

variable "sa_email" {
  description = "Service Account email"
  type        = string
}

variable "sa_scopes" {
  description = "Scope for Service Account"
  type        = list(string)
}

/*
# Optional: Alternative way to pass service account config
variable "service_account" {
  description = "Service account configuration"
  type = object({
    email  = string
    scopes = list(string)
  })
}
*/


###===================================================================================###
#                                 SSH and Metadata
###===================================================================================###

variable "ssh_user" {
  description = "User to SSH in as"
  type        = string
}

variable "ssh_key_file" {
  description = "Path to the SSH public key file"
  type        = string
}

variable "cloudinit_configfile" {
  description = "Path to the cloud-init YAML configuration file"
  type        = string
}

variable "vm_tags" {
  description = "Tags to assign to the VM for network/firewall configuration"
  type        = list(string)
}


###===================================================================================###
#                                Network Configuration
###===================================================================================###

variable "vpc_name" {
  description = "The name of the VPC network"
  type        = string
  default     = "default"
}

variable "subnet_name" {
  description = "The name of the subnetwork"
  type        = string
  default     = "default"
}

variable "public_ip_name" {
  description = "Name for the reserved public IP resource"
  type        = string
  default     = "karlv-pubip"
}

variable "private_ip_name" {
  description = "Name for the reserved private IP resource"
  type        = string
}

variable "private_ip" {
  description = "Static private IP address to assign to the VM"
  type        = string
}


###===================================================================================###
#                                      Locals
###===================================================================================###

locals {
  ssh_key_content    = file(var.ssh_key_file)
  cloudinit_config   = file(var.cloudinit_configfile)
}
