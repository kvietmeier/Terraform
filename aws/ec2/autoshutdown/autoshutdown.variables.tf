###===================================================================================###
#
#  File:  autoshutdown.variables.tf
#  Created By: Karl Vietmeier
#
###===================================================================================###

variable "region" {
  description = "AWS region for the scheduler and Lambda"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for IAM / Lambda / schedule names"
  type        = string
  default     = "solutions-lab"
}

variable "shutdown_cron" {
  description = "EventBridge Scheduler cron (6-field). Default: 19:00 Mon–Fri"
  type        = string
  default     = "cron(0 19 ? * MON-FRI *)"
}

variable "shutdown_timezone" {
  description = "IANA timezone for the cron expression"
  type        = string
  default     = "America/Los_Angeles"
}

variable "auto_shutdown_tag_key" {
  description = "Instance tag key that opts a VM into after-hours stop"
  type        = string
  default     = "AutoShutdown"
}

variable "auto_shutdown_tag_value" {
  description = "Tag value that enables stop (anything else / missing = skip)"
  type        = string
  default     = "true"
}

variable "common_tags" {
  description = "Tags on the Lambda / role / schedule"
  type        = map(string)
  default     = {}
}
