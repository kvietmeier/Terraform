###===================================================================================###
#
#  File:  variables.tf
#  Created By: Karl Vietmeier
#
#  Variable definitions with defaults
#
###===================================================================================###

### Provider Information
variable "region" {
  description = "Region to deploy resources"
}

variable "zone" {
  description = "Availbility Zone"
}

variable "project_id" {
  description = "GCP Project ID"
}

variable "vpc_name" {
  description = "Default VPC"
  default     = "default"
}

### Example Resource Variables

/* 
# String
variable "var_name" {
  description = "text here"
  type        = string
  default     = "default value"
}

# Boolean flag
variable "enable_feature_x" {
  description = "Enable or disable Feature X"
  type        = bool
  default     = false
}

# List of strings
variable "allowed_ip_ranges" {
  description = "List of CIDR blocks allowed through the firewall"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# Simple map of strings
variable "project_labels" {
  description = "Key-value map of labels to apply to all resources"
  type        = map(string)
  default = {
    environment = "dev"
    owner       = "karl"
    costcenter  = "cloud-infra"
  }
}

# Complex map of objects
variable "instance_configs" {
  description = "Map of instance names to their configuration"
  type = map(object({
    machine_type = string
    zone         = string
    tags         = list(string)
  }))
  default = {
    "web-1" = {
      machine_type = "e2-medium"
      zone         = "us-central1-a"
      tags         = ["web", "frontend"]
    },
    "db-1" = {
      machine_type = "n2-standard-2"
      zone         = "us-central1-b"
      tags         = ["db", "backend"]
    }
  }
}

*/