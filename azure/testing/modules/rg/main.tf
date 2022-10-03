###===================================================================================###
#  File:  main.tf
#  Created By: Karl Vietmeier
#
#  Terraform Template Code

#  Usage:
#  terraform apply --auto-approve -var-file=".\variables.tfvars"
#  terraform destroy --auto-approve -var-file=".\variables.tfvars"
###===================================================================================###


###===================================================================================###
#     Start creating infrastructure resources
###===================================================================================###

# Create a resource group
resource "azurerm_resource_group" "regionalrgs" {
  for_each  = var.region_map
  location  = "${each.value}"
  name      = "${var.prefix}"-"${each.key}"-"${var.suffix}"
}
