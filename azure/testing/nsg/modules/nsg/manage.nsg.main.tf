###===================================================================================###
#  File:  manage.nsg.main.tf
#  Created By: Karl Vietmeier
#
#  Goal: Maintain NSGs via Terraform - why?
#        * My ISP changes my IP every few months
#        * You may want to add a colleague's IP to the incoming filter.
# 
#  Usage:
#  terraform apply --auto-approve -var-file=".\manage.nsg.vars.tfvars"
#  terraform destroy --auto-approve -var-file=".\manage.nsg.vars.tfvars"
#
###===================================================================================###




###===================================================================================###
#    Create/Modify the NSG
###===================================================================================###

## To Do - 
/* 
* Create RG at the same time
* Create an NSG per region in region list
* Attach rules to each NSG
*/

resource "azurerm_resource_group" "nsgresources" {
  

}


# Create the NSG resource to hold the rules.
resource "azurerm_network_security_group" "primarynsg" {
  #location                     = "${var.region}"
  for_each             = [var.nsg_region ]
  location             = "${each.key}"
  resource_group_name  = data.azurerm_resource_group.westus2-rg.name
  name                 = "${var.region}-Inbound-${var.tf_suffix}"


# A "bulk" rule to allow access to a set of standard services (FTP, SSH, RDP, SMB, etc)
  security_rule {
    name                        = "CommonServices"
    access                      = "Allow"
    direction                   = "Inbound"
    priority                    = 100
    protocol                    = "Tcp"
    source_port_range           = "*"
    source_address_prefixes     = "${var.whitelist_ips}"
    destination_port_ranges     = "${var.destination_ports}"
    destination_address_prefix  = "*"
  }

}

# Map the NSG to the core vnet
#resource "azurerm_subnet_network_security_group_association" "mapnsg" {
#  subnet_id                 = element(azurerm_subnet.subnets[*].id, 0)
#  network_security_group_id = azurerm_network_security_group.upfnsg.id
#}
