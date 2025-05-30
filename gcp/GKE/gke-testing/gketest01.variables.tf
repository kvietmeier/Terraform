###===================================================================================###
#
#  File:  variables.tf
#  Created By: Karl Vietmeier
#
#  Variable definitions with defaults
#
###===================================================================================###


### Provider Settings
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
  description = "VPC to use"
  default     = "default"
}

variable "subnet_name" {
  description = "Subnet to use"
  default     = "default"
}

### GKE Cluster Vars
variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
  default     = "gcs-gke-cluster"
}

variable "gke_username" {
  default     = ""
  description = "gke username"
}

variable "gke_password" {
  default     = ""
  description = "gke password"
}

variable "gke_num_nodes" {
  default     = 2
  description = "number of gke nodes"
}
