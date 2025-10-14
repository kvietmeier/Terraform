###===================================================================================###
# File:         variables.tf
# Description:  Variable definitions for multi.main.tf using machine images
###===================================================================================###

# Project ID
variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

# Region
variable "region" {
  description = "The GCP region to deploy resources"
  type        = string
}

variable "tpu_region" {
  description = "The GCP region to deploy resources"
  type        = string
}



###--- VM Info

variable "service_account" {
  description = "The GCP region to deploy resources"
  type        = string
}

# Replace these variables with your desired values
variable "tpu_zone" {
  type        = string
  description = "The zone where the TPU will be created"
  default     = "us-central1-c" 
}

# Names of your existing resources
variable "vpc_name" {
  type        = string
  default = "your-existing-vpc-name" # <-- CHANGE THIS
}

variable "subnet_name" {
  type        = string
  default = "your-existing-subnet-name" # <-- CHANGE THIS
}

variable "service_account_email" {
  type        = string
  default = "sa-tpu-runner@your-gcp-project-id.iam.gserviceaccount.com" # <-- CHANGE THIS
}

# --- VARIABLES for Disk and TPU VM ---
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