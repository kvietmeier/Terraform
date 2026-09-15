variable "project_id" {
  type = string
}

variable "name" {
  type = string
}

variable "dns_name" {
  type = string
}

variable "description" {
  type = string
}

variable "network_urls" {
  type = list(string)
}

variable "fw_target" {
  description = "IPv4 of AD DNS server to forward to"
  type        = string
}
