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

###===============================#===================================================###
###--- Configure the Azure Active Directory Provider
###===================================================================================###
provider "azuread" {}


###===================================================================================###
#     Start creating infrastructure resources
###===================================================================================###

# Retrieve domain information
data "azuread_domains" "default" {
  only_initial = true
}

locals {
  domain_name = data.azuread_domains.default.domains.0.domain_name
  users       = csvdecode(file("${path.module}/users.csv"))
}


# Don't need this
resource "random_pet" "suffix" {
  length = 2
}

###--- Create users
resource "azuread_user" "users" {
  for_each = { for user in local.users : user.first_name => user }

  user_principal_name = format(
    "%s%s-%s@%s",
    substr(lower(each.value.first_name), 0, 1),
    lower(each.value.last_name),
    random_pet.suffix.id,
    local.domain_name
  )

  password = format(
    "%s%s%s!",
    lower(each.value.last_name),
    substr(lower(each.value.first_name), 0, 1),
    length(each.value.first_name)
  )
  force_password_change = true

  display_name = "${each.value.first_name} ${each.value.last_name}"
  department   = each.value.department
  job_title    = each.value.job_title
}