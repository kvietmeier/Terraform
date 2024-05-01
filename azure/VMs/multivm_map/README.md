### Create a multi-vm environment with 2 NICs per VM

This template builds a testing platform for distributed IaaS workloads leveraging:

* VMs configured in a map(object) so they can have different configs
* Proximity Placement Groups
* Network Security Groups
* 2 NICs per VM - one with a Public IP, one internal Only
* Deterministic/static IP assigment on NICs (For Ansible later)
* Accelerated Networking
* Bootdiags for Serial Console access
* cloud-init for OS setup
* Auto Shutdown enabled
* Peer vnet to existing hub vnet with Ansible/utilities server.

ToDo -

* Refactor to be module based
* Add data disks
* Document key template code that is poorly documented in general
* Use existing NSGs
* Better output
* Create storage - Azure Files or ANF

___

#### Code documentation - In Progress

Static IP assignment using cidrhost() - "hostnum" for IP is set in VM map.

```terraform

resource "azurerm_network_interface" "primary" {
  location                      = azurerm_resource_group.multivm_rg.location
  resource_group_name           = azurerm_resource_group.multivm_rg.name

  for_each = var.vmconfigs
  name     = "${each.value.name}-PrimaryNIC"
  enable_accelerated_networking = "true"

  ip_configuration {
    # This is the NIC with a PublicIP - 
    # --- only NICs flagged as primary can be accessed externally.
    primary                       = true
    name                          = "${each.value.name}-PrimaryCFG"
    subnet_id                     = azurerm_subnet.subnets["default"].id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(azurerm_subnet.subnets["default"].address_prefixes[0], each.value.hostnum)
    public_ip_address_id          = azurerm_public_ip.public_ips[each.key].id
  }
}

```

Creating the map(object) for the VMs in variables file

```terraform
# Create map(object) for VM configs
variable "vmconfigs" {
  description = "List of vms to create and the configuration for each."
  type = map(object(
      {
        name = string
        size = string
        hostnum = string   # For static IP
      }
    )
  )
}
```

Definition in tfvars - VMs can have different configurations:

```terraform
# VM Configs - keep it simple for now
# hostnum is for the static IP
# map syntax
vmconfigs = {
  "master" = {
    name    = "master"
    size    = "Standard_D2s_v5"
    hostnum = "5"
  },
  "worker1" = {
    name = "worker01"
    size = "Standard_D4ds_v5"
    hostnum = "6"
  },
  "worker2" = {
    name = "worker02"
    size = "Standard_D4ds_v5"
    hostnum = "7"
  },
  "worker3" = {
    name = "worker03"
    size = "Standard_D4ds_v5"
    hostnum = "8"
  }
}
```

___

#### My code is Built With

* [Visual Studio Code](https://code.visualstudio.com/) - Editor
* [Terraform](https://www.terraform.io/) - Terraform
* [Azure](portal.azure.com) - Azure Portal

#### All run under PowerShell on Windows 11

* [Windows Terminal](https://docs.microsoft.com/en-us/windows/terminal/) - Console

#### Author

* **Karl Vietmeier**

#### License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

#### Acknowledgments

* Intel colleagues
* Stack Exchange
* GitHub issues
* Terraform documentation
