###===================================================================================###
#
#  File:  variables.tf
#  Created By: Karl Vietmeier
#
#  Variable definitions with defaults
#
#  Added code to create VMs from a map
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


# Base name for VMs
variable "base_name" {
  type        = string
  description = "Base name for all VM instances"
  default     = "base-vm"
}

# Define the map
variable "vm_instances" {
  type = map(object({
    machine_type = string
    zone         = string
    disk_size_gb = number
    os_image     = string
    network      = string
    subnetwork   = string
    #cloudinit    = string
  }))
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

variable "cloudinit_configfile" {
  description = "Path to the cloud-init yaml"
  type        = string
}


###--- Network

# Network name
variable "vpc_name" {
  description = "The name of the VPC network"
  type        = string
  default     = "default"
}

variable "gcp_priv_dns" {
  description = "Private FQDN"
  type        = string
  default     = "c.clouddev-itdesk124.internal"
}

# Subnet name
variable "subnet_name" {
  description = "The name of the subnetwork"
  type        = string
  default     = "default"
}

variable "public_ip_name" {
  description = "name for a public IP"
  type        = string
  default     = "karlv-pubip"
}

# Read the SSH public key
locals {
  ssh_key_content = file(var.ssh_key_file)
}

# cloud-init file
locals {
  cloudinit_config = file(var.cloudinit_configfile)
}





###=================          unused                ==================###
/*
# Subnet CIDR range
variable "subnet_cidr" {
  description = "CIDR range for the subnet"
  type        = string
  default     = "10.0.0.0/24"
}
*/

###=================          Locals                ==================###



/*
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
*/



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