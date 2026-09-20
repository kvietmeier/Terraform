###===================================================================================###
#
#  File:  solutions-sre.main.tf
#  Created By: Karl Vietmeier
#
#  STATUS: NOT TESTED — generic template only. Validate before production apply.
#
#  Purpose: Define an IAM Identity Center permission set and assign it to
#           accounts + Identity Center groups/users. All names/IDs come from tfvars.
#
#  Intended lane: Solutions / SA / SRE workloads inside platform-provided VPCs.
#  Underlay (VPC/subnet/route/IGW/NAT/TGW) stays with platform/IT + Org SCP.
#
###===================================================================================###

data "aws_ssoadmin_instances" "this" {}

locals {
  sso_instance_arn  = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
}

resource "aws_ssoadmin_permission_set" "solutions_sre" {
  name             = var.permission_set_name
  description      = var.permission_set_description
  instance_arn     = local.sso_instance_arn
  session_duration = var.session_duration
  relay_state      = var.relay_state
  tags             = var.tags
}

resource "aws_ssoadmin_permission_set_inline_policy" "solutions_sre" {
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.solutions_sre.arn
  inline_policy      = data.aws_iam_policy_document.solutions_sre.json
}

resource "aws_ssoadmin_managed_policy_attachment" "readonly" {
  count = var.attach_readonly_managed_policy ? 1 : 0

  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.solutions_sre.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_ssoadmin_account_assignment" "this" {
  for_each = var.account_assignments

  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.solutions_sre.arn

  principal_id   = each.value.principal_id
  principal_type = each.value.principal_type

  target_id   = each.value.account_id
  target_type = "AWS_ACCOUNT"
}
