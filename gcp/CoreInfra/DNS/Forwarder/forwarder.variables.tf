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

###--- Forwarder Config 
variable "dns_name" {
  description = "The DNS name for the managed zone."
  type        = string
}

variable "name" {
  description = "Name of the resource"
  type        = string
}

variable "description" {
  description = "Description for the managed DNS zone."
  type        = string
}

variable "networks" {
  description = "A list of networks for private visibility."
  type        = list(string)
}

variable "vastcluser_dns" {
description = "DNS server on VAST cluster"
type = string
}

variable "forwarding_path" {
description = "Explicit;y make it private"
type = string
}