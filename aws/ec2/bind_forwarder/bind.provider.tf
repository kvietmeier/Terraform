###===================================================================================###
#
#  File:  bind.provider.tf
#  Created By: Karl Vietmeier
#
#  Purpose: Tiny Ubuntu EC2 BIND9 conditional forwarder for VAST DNS testing
#           when AWS Route 53 Resolver / Cloud DNS forwarding is unavailable.
#
#  Auth / region come from the environment:
#    AWS_PROFILE or AWS_DEFAULT_PROFILE
#    AWS_REGION  or AWS_DEFAULT_REGION (optional; overridden by var.region)
#
###===================================================================================###

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}
