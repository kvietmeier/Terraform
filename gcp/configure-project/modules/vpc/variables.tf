variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "vpc_name" {
  description = "Name of the custom VPC"
  type        = string
  default     = "custom-vpc"
}

variable "subnets" {
  description = "List of subnets with name, region, CIDR, and optional secondary ranges"
  type = list(object({
    name            = string
    region          = string
    ip_cidr_range   = string
    ipv6_cidr_range = optional(string)
    secondary_ip_ranges = optional(list(object({
      range_name    = string
      ip_cidr_range = string
    })))
  }))
}

variable "nat_enabled_regions" {
  description = "List of regions to deploy Cloud NAT"
  type        = list(string)
  default     = []
}
