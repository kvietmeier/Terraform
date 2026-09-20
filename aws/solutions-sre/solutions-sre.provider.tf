###===================================================================================###
#
#  File:  solutions-sre.provider.tf
#  Created By: Karl Vietmeier
#
#  STATUS: NOT TESTED — generic template only. Validate in a non-prod IdC admin
#          account before any production apply.
#
#  Purpose: AWS provider for an IAM Identity Center permission-set template.
#  Apply from the Identity Center / delegated-admin account (not a workload account).
#  Auth from env: AWS_PROFILE / AWS_REGION (or var.region = Identity Center region).
#
###===================================================================================###

terraform {
  required_version = ">= 1.5.0"

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
