###===================================================================================###
#
#  File:  terraform.tfvars
#  Created By: Karl Vietmeier
#
#  This is a "sanitized" version of the terraform.tfvars file that is excluded from the repo. 
#  Any values that aren't sensitive are left defined, amy sensitive values are stubbed out.
#
#  Edit as required
#
###===================================================================================###

###===================================================================================###
###                       VAST Cluster Provider Variable Values                       ###
###===================================================================================###

vast_user        = "admin"              # Replace with your VAST username
vast_passwd      = "123456"             # Replace with your VAST password
vast_host        = "vms"                # Replace with your VAST Cluster IP or hostname
vast_port        = 443
skip_ssl         = true                 # Set to false if SSL verification is required
validation_mode  = "strict"             # Options: "strict", "loose", etc.
