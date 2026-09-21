###===================================================================================###
#
#  File:  autoshutdown.auto.tfvars
#  Created By: Karl Vietmeier
#
###===================================================================================###

region = "us-west-2"

# 19:00 Mon–Fri Pacific — change cron/timezone as needed
shutdown_cron     = "cron(0 19 ? * MON-FRI *)"
shutdown_timezone = "America/Los_Angeles"

common_tags = {
  owned       = "solutions"
  used_by     = "solutions"
  Environment = "lab"
  Lifecycle   = "demo"
}
