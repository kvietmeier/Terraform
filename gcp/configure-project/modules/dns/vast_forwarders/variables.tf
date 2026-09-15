variable "project_id" {
  type = string
}

variable "network_urls" {
  type = list(string)
}

variable "forwarding_zones" {
  description = "Map of forwarding zones; key is the zone resource name"
  type = map(object({
    dns_name        = string
    vastcluser_dns  = string
    description     = string
    forwarding_path = optional(string, "private")
  }))
}

variable "forwarding_path" {
  type    = string
  default = "private"
}
