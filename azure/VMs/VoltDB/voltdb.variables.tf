####===================================================================================###
#   Copyright (C) 2022 Intel Corporation
#   SPDX-License-Identifier: Apache-2.0
###===================================================================================###
#
#  File:  variables.tf
#  Created By: Karl Vietmeier
#
#  Variable definitions with defaults
#
###===================================================================================###


variable "resource_group_name" {
  description = "Resource Group"
  default     = "TF-Testing"
}

variable "location" {
  description = "Region to deploy resources"
  default     = "westus2"
}

variable "prefix" {
  description = "A prefix to use for all resources"
  default     = "tf-testing"
}


### Volt vars
variable key_pair {
  description = "Amazon EC2 Key Pair"
  type = string
}

variable placement_group_strategy {
  type = string
  default = "cluster"
}

variable ami {
  description = "AMI ID"
  type = string
  default = "ami-0052f97d3bccfec9e"
}

variable clusterid {
  description = "XDCR clusterID. 0 means not in use."
  type = string
  default = "0"
}

variable sph {
  description = "sites per host"
  type = string
  default = "12"
}

variable k_factor {
  description = "Number of extra copies of data kept"
  type = string
  default = "1"
}

variable cmd_logging {
  description = "Set to Yes to emable command logging"
  type = string
  default = "true"
}

variable instance_type_parameter {
  description = "Default is m4.large."
  type = string
  default = "r7iz.4xlarge"
}

variable demo_parameter {
  description = "What you want to happen when system finishes booting"
  type = string
  default = "voltdb-charglt"
}

variable ssd_parameter {
  description = "Use transient SSDs if available. Not suitable for production."
  type = string
  default = "N"
}

variable password {
  description = "The database admin account password"
  type = string
  default = "idontknow"
}

variable cluster_name {
  description = "The name of this cluster"
  type = string
  default = "Demo"
}
