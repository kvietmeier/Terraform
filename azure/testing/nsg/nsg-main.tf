###===================================================================================###
#  File:  nsg-main.tf
#  Created By: Karl Vietmeier
#
#  Terraform Template Code
#  Purpose:  Module setup to create/maintain NSGs in an Azure subscription
#  Goal: Maintain NSGs via Terraform - why?
#        * My ISP changes my IP every few months
#        * You may want to add a colleague's IP to the incoming filter.
# 
#  Usage:
#  terraform apply --auto-approve -var-file=".\variables.tfvars"
#  terraform destroy --auto-approve -var-file=".\variables.tfvars"
###===================================================================================###


###===================================================================================###
#     Start creating infrastructure resources
###===================================================================================###

module "manage_nsg" {
  source = "./modules/nsg"


}