###===================================================================================###
#
#  File:  solutions-sre.outputs.tf
#  Created By: Karl Vietmeier
#
#  STATUS: NOT TESTED — generic template only. Validate before production apply.
#
###===================================================================================###

output "status" {
  value       = "NOT_TESTED — generic template; validate before production apply"
  description = "Explicit untested marker"
}

output "sso_instance_arn" {
  value       = local.sso_instance_arn
  description = "IAM Identity Center instance ARN"
}

output "identity_store_id" {
  value       = local.identity_store_id
  description = "Identity Store ID (lookup groups/users here)"
}

output "permission_set_arn" {
  value       = aws_ssoadmin_permission_set.solutions_sre.arn
  description = "Permission set ARN"
}

output "permission_set_name" {
  value       = aws_ssoadmin_permission_set.solutions_sre.name
  description = "Permission set name"
}

output "account_assignment_keys" {
  value       = keys(aws_ssoadmin_account_assignment.this)
  description = "Keys of account assignments created"
}

output "add_user_hint" {
  description = "How to add users after apply"
  value       = <<-EOT
    Prefer Identity Center groups over per-user assignments.
    1) Add the user to the IdC group (or IdP group synced to IdC).
    2) Resolve group id:
         aws identitystore list-groups --identity-store-id ${local.identity_store_id} \
           --filters AttributePath=DisplayName,AttributeValue='${var.idc_group_display_name}'
    3) Ensure account_assignments maps that group → target account(s); re-apply only if the map changed.
  EOT
}
