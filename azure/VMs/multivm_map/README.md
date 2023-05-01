### Create a multi-vm environment with 2 NICs per VM

This example will be using a map object to create multolie unique VMs.

This template will build a platform for testing Telco related workloads leveraging:

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
