###===================================================================================###
#
#  File:  variables.tf
#  Created By: Karl Vietmeier
#
#  Variable definitions with defaults
#
###===================================================================================###

# Project ID
variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

# Region
variable "region" {
  description = "The GCP region to deploy resources"
  type        = string
}

# Zone
variable "zone" {
  description = "The GCP zone to deploy the VM"
  type        = string
}


###--- VM Info
# Machine type for the VM
variable "machine_type" {
  description = "The machine type for the VM"
  type        = string
  default     = "e2-medium"
}

# VM instance name
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

###--- VM Metadata
# SSH 
variable "ssh_user" {
  description = "User to SSH in as"
  type        = string
}

variable "ssh_key_file" {
  description = "Path to the SSH public key file"
  type        = string
}


###--- Network
# Source IP allowed in the firewall rule
variable "source_ip" {
  description = "The IP address allowed in the firewall rule"
  type        = string
}

# Network name
variable "vpc_network" {
  description = "The name of the VPC network"
  type        = string
  default     = "custom-network"
}

# Subnet name
variable "subnet_name" {
  description = "The name of the subnetwork"
  type        = string
  default     = "custom-subnet"
}

# Subnet CIDR range
variable "subnet_cidr" {
  description = "CIDR range for the subnet"
  type        = string
  default     = "10.0.0.0/24"
}

###--- Firewall

# FW Name
variable "fw_rule_name" {
  description = "Name for rule"
  type        = string
}

# Allow list for Firewall Rules
variable whitelist_ips {
  description = "A list of IP CIDR ranges to allow as clients. Do not use Azure tags like `Internet`."
  type        = list(string)
}

# Destination Port list
variable destination_ports {
  description = "A list of standard network services: SSH, FTP, RDP, SMP, etc."
  type        = list(string)
}

# Network Protocol
variable "net_protocol" {
  description = "Network protocol"
  type        = string
  default     = "tcp"
}





###=================          Locals                ==================###

# Read the SSH public key
locals {
  ssh_key_content = file(var.ssh_key_file)
}



###=================  Examples of complex variables: =================###

###---  Storage Account Info
# Using type = list(object({}))
# Usage:  for_each = { for each in var.storage_account_configs : each.name => each }
# Referencing: storage_account_name = azurerm_storage_account.storage_acct["files"].name
/*
variable "storage_account_configs" {
  description = "Storage Account Definition"
  type = list(
    object(
      { name         = string,
        acct_kind    = string,
        account_tier = string,
        access_temp  = string,
        replication  = string
      }
    )
  )
}

###--- Fileshares
# Using type = list(object({}))
variable "shares" {
  description = "List of shares to create and their quotas."
  type = list(
    object(
      { name = string,
        quota = number 
      }
    )
  )
}


# Same thing but a list/map of multiple shares (simple key:value)
variable "file_shares" {
  description = "List of shares to create and their quotas."
  type        = map(any)
}

*/