# Install the Active Directory Domain Services (AD DS) role
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# Import the ADDSDeployment module
Import-Module ADDSDeployment

# Promote the server to a Domain Controller
Install-ADDSForest -DomainName "ginaz.org" `
    -DomainNetbiosName "ginaz" `
    -InstallDns:$true `
    -NoRebootOnCompletion:$false `
    -SafeModeAdministratorPassword (ConvertTo-SecureString -String "Chalc0pyr1te!123" -AsPlainText -Force)

# Reboot the system if necessary
Restart-Computer

# Create a new Organizational Unit (OU)
New-ADOrganizationalUnit -Name "VAST" -Path "DC=ginaz,DC=org"

# Redirect new computer accounts to the new OU
redircmp "OU=VAST,DC=ginaz,DC=org"

# Move existing computer accounts if needed
Get-ADComputer -SearchBase "CN=Computers,DC=ginaz,DC=org" -Filter * |
ForEach-Object {
    Move-ADObject -Identity $_.DistinguishedName -TargetPath "OU=Workstations,DC=ginaz,DC=org"
}

# Enable Remote Desktop for local Administrator login
# Ensure that RDP is enabled
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\' -Name 'fDenyTSConnections' -Value 0

# Enable the local Administrator account
Enable-LocalUser -Name "Administrator"

# Add the local Administrator account to the "Remote Desktop Users" group
Add-LocalGroupMember -Group "Remote Desktop Users" -Member "Administrator"

# Set the Administrator password
$password = ConvertTo-SecureString "Chalc0pyr1te!123" -AsPlainText -Force
Set-LocalUser -Name "Administrator" -Password $password###===================================================================================###
#
#  File:  Template.tf
#  Created By: Karl Vietmeier
#
#  Terraform Module Code
#  Purpose:  Create a Windows Server VM for Infrastructure
# 
###===================================================================================###

/* 

Put Usage Documentation here

*/


###===================================================================================###
#     Start creating infrastructure resources
###===================================================================================###

# Reserve a specific static external (public) IP address
resource "google_compute_address" "vm_public_ip" {
  name         = var.public_ip_name
  address_type = "EXTERNAL"
  region       = var.region
}

resource "google_compute_address" "vm_private_ip" {
  name         = var.private_ip_name
  address_type = "INTERNAL"
  subnetwork   = var.subnet_name
  region       = var.region
  address      = var.private_ip
}


#
###=================   Create VM instance with public IP   ===================###
#
resource "google_compute_instance" "vm_instance" {
  zone         = var.zone             # Use the zone variable
  name         = var.vm_name          # Use the vm_name variable
  machine_type = var.machine_type     # Use the machine_type variable

  boot_disk {
    initialize_params {
      image    = var.os_image         # Replace with your preferred image
      size     = var.bootdisk_size
    }
  }

  # Configure the network interface with the specified private and public IPs
  network_interface {
    subnetwork    = var.subnet_name
    network_ip    = google_compute_address.vm_private_ip.address  # Specified static private IP
    
    # Enables a public IP address
    access_config {
      # Specified static public IP
      nat_ip = google_compute_address.vm_public_ip.address
    }
  }

  metadata = {
    
    # Set the Timezone
    #"user-data" = <<EOF
    #powershell -Command "tzutil /s 'Pacific Standard Time'" 
    #EOF
    
    # Windows post install config
    enable-windows-automatic-updates    = "true"
    sysprep-specialize-script-ps1       = "${file(var.windows-sysprep-script)}"
  }

  tags = var.vm_tags
  
  service_account {
    # Google recommends custom service accounts with `cloud-platform` scope with
    # specific permissions granted via IAM Roles.
    email  = var.sa_email
    scopes = var.sa_scopes
  }
}
#
###===================       End VM Resource Block       ===================###
#


###===================   Outputs  ===================###

# Output the public IP address
output "public_ip" {
  value       = google_compute_address.vm_public_ip.address
  description = "Reserved public IP address for the VM"
}

# Output the private IP address
output "private_ip" {
  value = google_compute_instance.vm_instance.network_interface[0].network_ip
  description = "The private IP address of the VM instance."
}###===================================================================================###
#
#  File:  provider.tf
#  Created By: Karl Vietmeier
#
#  Purpose: Configure the GCP Provider TerraForm
# 
#  Google defaults set as Env: vars
#
###===================================================================================###


terraform {
  required_providers {
  google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}###===================================================================================###
#
#  File:  submodule.tf
#  Created By: Karl Vietmeier
#
#  Terraform Module Code
#  Purpose:  Blank Template for extra resources
# 
###===================================================================================###

/* 

Put Usage Documentation here

*/


###===================================================================================###
#     Start creating resources
###===================================================================================######===================================================================================###
#
#  File: winserver2201.terraform.tfvars
#  Created By: Karl Vietmeier
#
#  This file should be excluded from your github repo
#
###===================================================================================###

# Project Info
project_id      = "clouddev-itdesk124"
region          = "us-west2"
zone            = "us-west2-b"

# Service Account/s
sa_email        = "913067105288-compute@developer.gserviceaccount.com"
sa_scopes       = ["cloud-platform"]

# VM Info
private_ip      = "172.20.16.3"
public_ip_name  = "w22server01-public-ip"
private_ip_name = "w22server01-private-ip"
vm_name         = "w22server01"
machine_type    = "c2-standard-4"
os_image        = "windows-server-2022-dc-v20241115"
bootdisk_size   = "400"
vm_tags         = [ "karlv-vms", "karlv-windows", "karlv-infra" ]
windows-sysprep-script = "../../../scripts/windows-sysprep-config.ps1"

# VPC Config - existing
vpc_name        = "karlv-corevpc"
subnet_name     = "subnet-hub-us-west2"
###===================================================================================###
#
#  File:  terraform.tfvars
#  Created By: Karl Vietmeier
#
#  This is a "sanitized" version of the terraform.tfvars file that is excluded from the repo. 
#  Any values that aren't sensitive are left defined, amy sensitive values are stubbed out.
#
#  Edit as required
#
###===================================================================================###

project_id = "your-project-id"
source_ip  = "<my_ip>"


###======  Examples (Azure):
###======================== Define values for the complex variables  =======================###
# Storage Account configurations
storage_account_configs = [
  {
    name         = "files"
    acct_kind    = "FileStorage" # Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2.
    account_tier = "Premium"     # If "Premium" - it must be in a "FileStorage" Storage Account
    access_temp  = "Hot"
    replication  = "LRS"
  },
  {
    name         = "blobs"
    acct_kind    = "BlobStorage" # Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2.
    account_tier = "Standard"    # 
    access_temp  = "Hot"
    replication  = "LRS"
  }
]

#- Fileshares using complex object syntax
shares = [
  {
    name  = "volume01",
    quota = "100"
  },
  {
    name  = "volume02",
    quota = "150"
  },
  {
    name  = "volume03",
    quota = "200"
  }
]

### - List/map of multiple shares - using simple map
file_shares = {
  "volume01" = "100",
  "volume02" = "100",
  "volume03" = "250"
}###===================================================================================###
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

# Service Account
variable "sa_email" {
  description = "Service Account email"
  type        = string
}

variable "sa_scopes" {
  description = "Scope for Service Account"
  type        = list(string)
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
  default     = "windows-server-2022-dc-v20241115"
}

variable "bootdisk_size" {
  description = "Size of boot disk in GB"
  type        = string
  default     = "150"
}

###--- VM Metadata
variable "windows-sysprep-script" {
  description = "Windows config script"
  type        = string
}

variable vm_tags {
  description = "Tags"
  type        = list(string)
}


###--- Network

# Network name
variable "vpc_name" {
  description = "The name of the VPC network"
  type        = string
  default     = "default"
}

# Subnet name
variable "subnet_name" {
  description = "The name of the subnetwork"
  type        = string
  default     = "default"
}

variable "public_ip_name" {
  description = "Name for Private IP"
  type        = string
  default     = "karlv-pubip"
}

variable "private_ip_name" {
  description = "Name for Public IP"
  type        = string
}

variable "private_ip" {
  description = "Static Private IP"
  type        = string
}

/*
# Subnet CIDR range
variable "subnet_cidr" {
  description = "CIDR range for the subnet"
  type        = string
  default     = "10.0.0.0/24"
}
*/

###=================          Locals                ==================###


# cloud-init file
locals {
  windows-sysprep = file(var.windows-sysprep-script)
}


