###==================================================================================###
#  File:  terraform.tfvars.txt
#  Created By: Karl Vietmeier
#  
#  The terraform.tfvars file with sensitive values is in .gitignore.
#  This file is a tenmplate that you can rename amd populate as needed.
#  
#  This should be in .gitignore
#
###==================================================================================###

# Basic Information - need the actual region name because we use it in the NSG Name
prefix  = "z_nsg"
suffix  = "Managed"

# Have to put everything in one RG
resource_group = "karlv-voctesting"

# Regions to create NSGs in:
region_map = {
  "WUS"  = "westus",
  "WUS2" = "westus2",
  "WUS3" = "westus3",
  "CUS"  = "centralus",
  "EUS"  = "eastus",
  "EUS2" = "eastus2"
}

# Destination port list - standard services you might need
destination_ports = [ "20", "21", "22", "45", "53", "88", "443", "3389", "8080" ]

# NSG Allow List - modify as needed
whitelist_ips = [ 
    "47.144.103.245", # My ISP Address
    "47.37.190.104",  # Noel's house
    "104.167.209.0"   # Mobile Location
]
