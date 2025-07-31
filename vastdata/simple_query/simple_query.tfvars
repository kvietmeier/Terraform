#====================================================================================#
# VAST Data Provider Authentication Test - Input Variables for testapply.main.tf
#
# Usage:
#   terraform apply -auto-approve -var-file=testapply.terraform.tfvars
#
# Adjust values below to match your VAST cluster credentials and connection details.
#====================================================================================#

###===================================================================================###
# Provider Configuration
###===================================================================================###

vast_username                = "admin"
vast_password                = "123456"
vast_host                    = "vms"
vast_port                    = "443"
vast_skip_ssl_verify         = true
vast_version_validation_mode = "warn"
