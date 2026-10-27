###===================================================================================###
#
#  File:  clients.provider.tf
#  Created By: Karl Vietmeier
#
#  Purpose: Configure the AWS provider
#
#  Auth / region come from the environment (same idea as vastdata/provider):
#    AWS_PROFILE or AWS_DEFAULT_PROFILE  — SSO / shared-config profile
#    AWS_REGION  or AWS_DEFAULT_REGION    — optional; overridden by var.region below
#    AWS_ACCESS_KEY_ID / SECRET / SESSION_TOKEN — if not using a profile
#
#  Do not put profile names or credentials in this file.
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
  # No profile= — uses AWS_PROFILE / default credential chain from the shell
}
