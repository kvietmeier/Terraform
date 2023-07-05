###===================================================================================###
#   Copyright (C) 2022 Intel Corporation
#   SPDX-License-Identifier: Apache-2.0
###===================================================================================###
#  File:  manage_users.main.tf
#  Created By: Karl Vietmeier
#
#  Terraform Template Code
#  Purpose: Maintain a list of users in the Tenant
#
#  TBD - Assign subscription ownership to users
#
#
###===================================================================================###


# Retrieve domain information
data "azuread_domains" "default" {
  # Use the primary domain for UPN
  only_default = true
}

locals {
  # Primary domain
  domain_name = data.azuread_domains.default.domains.0.domain_name
  
  # Get settings from csv file
  users = csvdecode(file("${path.module}/users.csv"))
}


###--- Create users
# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/user
resource "azuread_user" "users" {
  # Get settings from csv file
  for_each = { for user in local.users : user.first_name => user }

  user_principal_name = format(
    "%s%s@%s",
    substr(lower(each.value.first_name), 0, 1),
    lower(each.value.last_name),
    local.domain_name
  )
  
  password = var.password
  force_password_change = false

  display_name    = "${each.value.first_name} ${each.value.last_name}"
  department      = each.value.department
  job_title       = each.value.job_title
  company_name    = each.value.company_name
  account_enabled = each.value.enabled

}

###--- Subscription Information
# Using "current" retrieves active subscription - I only have one so this works.
data "azurerm_subscription" "current" {
}

output "current_subscription_display_name" {
  value = data.azurerm_subscription.current.display_name
}

output "current_subscription_id" {
  value = data.azurerm_subscription.current.id
}

###--- AD Group Info
data "azuread_group" "subscription_contributors" {
  display_name = "Subscription Admins"
}

resource "azuread_group_member" "sub_admins" {
  # Loop through users and find admins
  for_each = { for user in local.users : user.first_name => user if user.sub_admin =="true"}
  
  # Assign to Group
  group_object_id  = data.azuread_group.subscription_contributors.id
  member_object_id = azuread_user.users[each.key].id

}