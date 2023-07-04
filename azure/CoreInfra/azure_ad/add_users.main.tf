###===================================================================================###
#  File:  add_users.main.tf
#  Created By: Karl Vietmeier
#
#  Terraform Template Code
#  Purpose: Maintain a list of users in the Tenant
#
#  Files in Module:
#    add_users.main.tf
#    add_users.variables.tf
#    add_users.variables.tfvars
#    add_users.variables.tfvars.txt
#
#  Usage:
#  terraform apply --auto-approve -var-file=".\add_users.variables.tfvars"
#  terraform destroy --auto-approve -var-file=".\add_users.variables.tfvars"
#
###===================================================================================###


###===================================================================================###
#     Start creating infrastructure resources
###===================================================================================###

# Retrieve domain information
data "azuread_domains" "default" {
  #only_initial = true
  only_default = true
}

locals {
  domain_name = data.azuread_domains.default.domains.0.domain_name
  users       = csvdecode(file("${path.module}/users.csv"))
}


###--- Create users
# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/user
resource "azuread_user" "users" {
  for_each = { for user in local.users : user.first_name => user }

  user_principal_name = format(
    "%s%s@%s",
    substr(lower(each.value.first_name), 0, 1),
    lower(each.value.last_name),
    local.domain_name
  )

  /*   
    password = format(
    "%s%s%s!",
    lower(each.value.last_name),
    substr(lower(each.value.first_name), 0, 1),
    length(each.value.first_name)
  ) 
  */
  
  password = "Chalc0pyrite"
  force_password_change = false

  # Get settings from csv file
  display_name = "${each.value.first_name} ${each.value.last_name}"
  department   = each.value.department
  job_title    = each.value.job_title
  company_name = each.value.company_name
  account_enabled = each.value.enabled
}