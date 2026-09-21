###===================================================================================###
#
#  File:  autoshutdown.provider.tf
#  Created By: Karl Vietmeier
#
#  After-hours stop for tagged lab / scratch workloads.
#  Do not opt in long-running services or always-on infrastructure.
#
#  Auth from env (AWS_PROFILE / credential chain). Region from var.region.
#
###===================================================================================###

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.region
}
