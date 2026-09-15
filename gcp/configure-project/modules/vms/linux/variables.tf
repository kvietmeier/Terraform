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
  default = "centos-stream-9-v20241009"
}

variable "bootdisk_size" {
  type    = string
  default = "40"
}

variable "sa_email" {
  type = string
}

variable "sa_scopes" {
  type    = list(string)
  default = ["cloud-platform"]
}

variable "ssh_user" {
  type = string
}

variable "ssh_key_file" {
  description = "Path to SSH public key file"
  type        = string
}

variable "cloudinit_configfile" {
  description = "Path to cloud-init YAML"
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
