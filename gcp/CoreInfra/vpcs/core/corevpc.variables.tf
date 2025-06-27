###========================================================================================###
##  Variable Definitions for VPC Infrastructure Deployment
##
##  - Defines input variables for region, zone, project ID, and VPC settings
##  - Includes subnet configuration with optional IPv6 and secondary ranges
##  - Specifies regions where Cloud NAT should be enabled
##
##  These variables are used across modules to provision a custom network topology.
###========================================================================================###

###--- Provider Info
variable "region" {
  description = "Region to deploy resources"
}

variable "zone" {
  description = "Availbility Zone"
}

variable "project_id" {
  description = "GCP Project ID"
}

# --- VPC Settings ---
variable "default_region" {
  description = "Default region"
  type        = string
  default     = "us-west2"
}

variable "vpc_name" {
  description = "Name of the custom VPC"
  type        = string
  default     = "custom-vpc"
}

# --- Subnet Definitions ---
/* 
List of subnet definitions. Each entry includes:
- name: Subnet name
- region: GCP region
- ip_cidr_range: Primary IPv4 CIDR block
- ipv6_cidr_range (optional): IPv6 block (for dual-stack subnets)
- secondary_ip_ranges (optional): Additional named secondary CIDR blocks (e.g., for services)
*/
variable "subnets" {
  description = "List of subnets with name, region, CIDR, and secondary cidr ranges"
  type = list(object({
    name                = string
    region              = string
    ip_cidr_range       = string
    ipv6_cidr_range     = optional(string)
    secondary_ip_ranges = optional(list(object({
      range_name    = string
      ip_cidr_range = string
    })))
  }))
}

# --- Cloud NAT Configuration ---
variable "nat_enabled_regions" {
  description = "List of regions to deploy Cloud NAT"
  type        = list(string)
  default     = []
}