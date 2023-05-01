### Create a multi-vm environment with 2 NICs per VM

This template build a testing platform for Telco related workloads leveraging:

* VMs configured in a map(object) so they can have different configs
* Proximity Placement Groups
* Network Security Groups
* 2 NICs per VM - one with a Public IP, one internal Only
* Deterministic/static IP assigment on internal NIC
* Accelerated Networking
* Bootdiags for Serial Console access
* cloud-init for OS setup
* Auto Shutdown enabled
* Peer vnet to existing hub vnet with Ansible/utilities server.

ToDo -

* Refactor to be module based
* Document key template code that is poorly documented in general
* Use existing NSGs
* Better output

#### Code documentation - In Progress

Static IP assignment using cidrhost() - "hostnum" is set in VM map

```terraform
  ip_configuration {
    primary                       = false
    name                          = "${each.value.name}-InternalCFG"
    #private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.subnets["internal"].id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(azurerm_subnet.subnets["internal"].address_prefixes[0], each.value.hostnum)
  }
```

Creating the map(object) for the VMs

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

Definition in tfvars:

```terraform
# VM Configs - keep it simple for now
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

#### All run under PowerShell on Windows 10

* [Windows Terminal](https://docs.microsoft.com/en-us/windows/terminal/) - Console

#### Author

* **Karl Vietmeier**

#### License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

#### Acknowledgments

* Intel colleagues
* Stack Exchange
* GitHub issues
* Terraform documenmtation
