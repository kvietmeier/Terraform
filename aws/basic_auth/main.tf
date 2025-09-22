terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  profile = "AWS-POC-VOC-Admin"
  region  = "us-west-2"
}

# Just fetch caller ide"ntity (no resources created)
data "aws_caller_identity" "current" {}
output "account_id" {
  value = data.aws_caller_identity.current.account_id
}
output "caller_arn" {
  value = data.aws_caller_identity.current.arn
}
output "user_id" {
  value = data.aws_caller_identity.current.user_id
}
