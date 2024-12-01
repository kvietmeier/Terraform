###===================================================================================###
#
#  File:  Template.tf
#  Created By: Karl Vietmeier
#
#  Terraform Module Code
#  Purpose:  
# 
#  Files in Module:
#    main.tf
#    variables.tf
#    variables.tfvars
#
###===================================================================================###


/* 
  
Usage:
terraform plan -var-file=".\multivm_map.tfvars"
terraform apply --auto-approve -var-file=".\multivm_map.tfvars"
terraform destroy --auto-approve -var-file=".\multivm_map.tfvars"

*/


###===================================================================================###
#     Start creating infrastructure resources
###===================================================================================###