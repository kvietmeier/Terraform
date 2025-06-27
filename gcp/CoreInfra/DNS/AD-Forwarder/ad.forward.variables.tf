###===================================================================================###
#
#  File:  forwarder.variables.tf
#  Created By: Karl Vietmeier
#
#   This file defines all required input variables for deploying a DNS forwarding zone
#   in Google Cloud, typically used to forward queries to an external DNS server such
#   as an Active Directory DNS on a VAST cluster.
#
###===================================================================================###

###--- GCP Provider Configuration
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

###--- DNS Zone Configuration
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

variable "fw_target" {
description = "DNS server on VAST cluster"
type = string

}