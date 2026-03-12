###===================================================================================###
#
#  File:  terraform.tfvars
###===================================================================================###
#
#  File:  private.auto.tfvars
#  Created By: Karl Vietmeier
#
#  Purpose:  Define sensitive, project-specific, or user-specific variable values
#            for a Terraform configuration. This file contains values that should
#            **not** be committed to version control.
#
#  Notes:
#   - Terraform automatically loads this file when running commands (plan/apply).
#   - This file is explicitly listed in `.gitignore` to prevent accidental commits.
#   - This is the ideal location for sensitive data like private IPs, secrets, or API keys.
#
###===================================================================================###
