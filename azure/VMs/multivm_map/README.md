### Create a multi-vm enviroment with 2 NICs per VM

This example will be using a map object to create multolie unique VMs.

This template will build a platform for testing Telco related workloads leveraging:

* Proximity Placement Groups
* Network Security Groups
* 2 NICs per VM - one with a Publlic IP, one internal Only
* Accelerated Networking
* Bootdiags for Serial Console access
* cloud-init for OS setup
* Auto Shutdown enabled
* Peer vnet to existing hub vnet with Ansible/utilities server.

ToDo -

* Refactor to be module based
* Document key template code that is poorly documented in general.
* Use existing NSGs
* Add Azure Arc agent

Need to document steps better  

**NOTE: Due to some logic it will only create 2 VMs!  Need to fix it.**

Creating multpile VMs with 2 NICs is not as straightforward as it seems.

#### Code documentation - In Progress

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
