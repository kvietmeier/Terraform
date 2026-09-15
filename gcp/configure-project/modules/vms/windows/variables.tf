variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "zone" {
  type = string
}

variable "machine_type" {
  type    = string
  default = "e2-medium"
}

variable "vm_name" {
  type = string
}

variable "os_image" {
  type    = string
  default = "windows-server-2022-dc-v20241115"
}

variable "bootdisk_size" {
  type    = string
  default = "150"
}

variable "sa_email" {
  type = string
}

variable "sa_scopes" {
  type    = list(string)
  default = ["cloud-platform"]
}

variable "windows_sysprep_script" {
  description = "Path to Windows sysprep PowerShell script"
  type        = string
}

variable "vm_tags" {
  type    = list(string)
  default = []
}

variable "subnet" {
  description = "Subnet name or self_link"
  type        = string
}

variable "public_ip_name" {
  type = string
}

variable "private_ip_name" {
  type = string
}

variable "private_ip" {
  type = string
}

variable "assign_public_ip" {
  type    = bool
  default = true
}
