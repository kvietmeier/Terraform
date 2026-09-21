###===================================================================================###
#
#  File:  autoshutdown.outputs.tf
#  Created By: Karl Vietmeier
#
###===================================================================================###

output "schedule_name" {
  value       = aws_scheduler_schedule.autoshutdown.name
  description = "EventBridge Scheduler name"
}

output "lambda_name" {
  value       = aws_lambda_function.autoshutdown.function_name
  description = "Lambda that stops tagged instances"
}

output "policy_summary" {
  description = "How to opt VMs in/out"
  value       = <<-EOT
    After-hours stop: ${var.shutdown_cron} (${var.shutdown_timezone})
    Opt in:  tag ${var.auto_shutdown_tag_key}=${var.auto_shutdown_tag_value}
    Opt out: omit tag or set ${var.auto_shutdown_tag_key}=false
    Leave unset on long-running services and always-on hosts.
  EOT
}
