###===================================================================================###
#  File:         tpu_nodes.variables.tf
#  Created By:   Karl Vietmeier / KCV Consulting
#  License:      Licensed under the Apache License, Version 2.0
#                http://www.apache.org/licenses/LICENSE-2.0
#
#  Description:  Variable definitions for TPU node deployment.
#                Includes project settings, network configuration, TPU VM parameters,
#                and optional data disk settings.
###===================================================================================###


###===================================================================================###
#                         Project & Region Settings
###===================================================================================###

# The GCP project ID where resources will be deployed
variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

# The primary region for the Project
variable "region" {
  description = "The GCP region to deploy resources"
  type        = string
}

# The TPU-specific region (can be different from the primary region)
variable "tpu_region" {
  description = "The GCP region to deploy resources"
  type        = string
}


###===================================================================================###
#                         TPU VM / Service Account Info
###===================================================================================###

# The GCP service account used by the TPU VM
variable "service_account" {
  description = "The GCP service account used by the TPU VM"
  type        = string
}

# The zone where the TPU will be created
variable "tpu_zone" {
  type        = string
  description = "The zone where the TPU will be created"
  default     = "us-central1-c" 
}

# --- Names of existing network resources ---
variable "vpc_name" {
  type        = string
  default = "your-existing-vpc-name" # <-- CHANGE THIS
}

variable "subnet_name" {
  type        = string
  default = "your-existing-subnet-name" # <-- CHANGE THIS
}

/* # Optional alternative: service account email variable
variable "service_account_email" {
  type        = string
}
 */

###===================================================================================###
#                         TPU Data Disk Settings
###===================================================================================###

variable "tpu_disk_size_gb" {
  description = "Size of the data disk in GB."
  type        = number
  default     = 100 
}

variable "tpu_disk_type" {
  description = "Type of the persistent disk (e.g., pd-ssd, pd-standard)."
  type        = string
  default     = "pd-ssd"
}


###===================================================================================###
#                         TPU VM Configuration
###===================================================================================###

variable "tpu_accelerator_type" {
  description = "The desired TPU accelerator size (e.g., v3-8, v5litepod-8)."
  type        = string
  default     = "v3-8" # Default set to the working type
}

variable "tpu_cidr_block" {
  description = "The /29 CIDR block for the TPU node's internal network."
  type        = string
  default     = "172.11.1.0/29"
}

variable "tpu_name" {
 type        = string
 description = "The name of the TPU node." 
}

variable "tpu_runtime" {
  type = string
}

variable "tpu_description" {
  type = string
  default = "TPU VM created via Terraform"
}