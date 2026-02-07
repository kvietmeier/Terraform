###===================================================================================###
#  Created By:  Karl Vietmeier
#  Purpose:     De Novo NVIDIA Blackwell Workstation Deployment (Ubuntu 24.04)
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
###===================================================================================###

# --- Project & Location ---
variable "project_id" { type = string }
variable "region"     { type = string }
variable "zone"       { type = string }

# --- VM Configuration ---
variable "vm_name" { type = string }
variable "vm_tags" { type = list(string) }

variable "machine_type" {
  type        = string
  description = "Must be g4-standard-96 for Blackwell"
  default     = "g4-standard-96"
}

variable "os_image" {
  type        = string
  description = "Must be Ubuntu 24.04 for Driver 580+"
  default     = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
}

variable "bootdisk_size" {
  type    = string
  default = "100"
}

variable "h_disk_type" {
  type        = string
  default     = "hyperdisk-balanced" 
  description = "Options: hyperdisk-balanced, hyperdisk-extreme, hyperdisk-performance"
}

variable "h_disk_size" {
  type    = string
  default = "250"
}

# --- Network ---
variable "vpc_name"    { 
  type = string
}

variable "subnet_name" {
  type = string
}

# --- Service Account ---
variable "sa_email"  {
  type = string
  }

variable "sa_scopes" {
  type = list(string)
  }

# --- SSH & Legacy Config ---
variable "ssh_user"     {
  type = string
  }

variable "ssh_key_file" {
  type = string
  }

variable "personal_repo" {
  type    = string
  default = ""  # will fallback to env var
}

### Locals to set file locations
locals {
  # Use the variable or fallback
  personal_repo   = var.personal_repo != "" ? var.personal_repo : "/home/karlv/projects/personal"

  # Path to your key file inside the personal repo
  ssh_key_file    = "${local.personal_repo}/secrets/ssh_keys.txt"

  # Read the content
  ssh_key_content = file(local.ssh_key_file)
}