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



###---  Standard Values
# Provider Information
project_id      = "clouddev-itdesk124"
region          = "us-west2"
zone            = "us-west2-a"


user_emails    = [
  "karl.vietmeier@vastdata.com",
  "leonid.vaiman@vastdata.com",
  "ronnie.lazar@vastdata.com",
  "kiran.kumar@vastdata.com",
  "chris.snow@vastdata.com",
  "josh.wentzell@vastdata.com",
  "casey.golliher@vastdata.com",
  "daniel.beres@vastdata.com",
  "sven.breuner@vastdata.com",
  "bryan.gilcrease@vastdata.com",
  "blake.golliher@vastdata.com",
  "kartik@vastdata.com",
  "billykettler@google.com",
  "kv82579@gmail.com"
]
