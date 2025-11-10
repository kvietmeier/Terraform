###===================================================================================###
#
#  File:  forwarder.variables.tf
#  Created By: Karl Vietmeier
#
#  Variable definitions with defaults
#
###===================================================================================###

# variables.tf
###--- Provider Info
variable "region" {
  description = "Region to deploy resources"
}

variable "zone" {
  description = "Availbility Zone"
}

variable "project_id" {
  description = "The ID of the Google Cloud project."
  type        = string
}

# Example of what your updated variables.tf should look like
variable "forwarding_zones" {
  description = "A map of forwarding zones to create. Key is the zone ID."
  type = map(object({
    dns_name          = string
    vastcluser_dns    = string # The IP of the target DNS server
    description       = string
    forwarding_path   = optional(string, "private") # Add as an optional if you want to keep it simple
  }))

}

# The existing variables like project_id, region, zone, and networks will still be needed.
# For simplicity, I'm assuming 'networks' will apply to *both* zones.
# Fixes the error: "Reference to undeclared input variable networks"
variable "networks" {
  description = "List of network names to bind the private DNS zone(s) to."
  type        = list(string)
}

# Fixes the error: "Reference to undeclared input variable forwarding_path"
# (Used as a fallback path in the 'try' function within the main.tf resource)
variable "forwarding_path" {
  description = "The service to use for the DNS forwarding, typically 'default' or 'private'."
  type        = string
  default     = "private"
}