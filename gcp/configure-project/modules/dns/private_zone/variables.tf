variable "project_id" {
  type = string
}

variable "zone_name" {
  description = "Cloud DNS managed zone resource name"
  type        = string
  default     = "vastclusters"
}

variable "dns_name" {
  description = "DNS name for the managed zone (must end with a dot)"
  type        = string
}

variable "description" {
  type = string
}

variable "network_urls" {
  description = "List of VPC network URLs / self_links for private visibility"
  type        = list(string)
}

variable "a_records" {
  description = "Map of subdomain => list of IPs"
  type        = map(list(string))
  default     = {}
}
