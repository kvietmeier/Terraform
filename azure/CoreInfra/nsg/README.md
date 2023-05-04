### Manage a set of Network Security Groups across regions

**Use Case:**  
My ISP changes my router IP address every 3 nmonths, forcing me to update all of my NSG to change the incoming IP address filter.

Doing this by hand was cumbersome.

Using list variables and for_each allows me to maintain a set of N_numder of NSG across regions and update them all with a simple edit and "terraform apply"

```terraform
# Create resource groups from a map
resource "azurerm_resource_group" "regionalrgs" {
  for_each  = var.region_map
  location  = "${each.value}"
  name      = "${var.prefix}-${each.key}-${var.suffix}"
}

# Create the NSG resources for each resource group/region
resource "azurerm_network_security_group" "default-nsg" {
  for_each             = var.region_map
  location             = "${each.value}"
  resource_group_name  = azurerm_resource_group.regionalrgs[each.key].name
  name                 = "${each.key}-InboundNSG"

# A "bulk" rule to allow access to a set of standard services (FTP, SSH, RDP, SMB, etc)
# We want the same rule for all regions - this rule filters incoming traffic on the source IP
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
```

Destination Ports:

```terraform
# Destination port list - standard services you might need
destination_ports = [ "20", "21", "22", "45", "53", "88", "443", "3389", "8080" ]
```

IP Allow list:

```terraform
# NSG Allow List - modify as needed
whitelist_ips = [
  "0.0.0.0",    # My ISP Address
  "0.0.0.0/27"  # A range of IPs
]
```

#### Authors

- **Karl Vietmeier**

#### License

This project is licensed under the Apache License - see the [LICENSE.md](../LICENSE.md) file for details

#### Acknowledgments

- None so far other than the many good examples out there.
