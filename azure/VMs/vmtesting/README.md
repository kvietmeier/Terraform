### Create a multi-vm enviroment with 2 NICs per VM

The goal is to build a platform for investigating VM instance features/functionality and explore advanced topics like:

* Bootdiags for Serial Console access
* cloud-init for OS setup
* Auto Shutdown
* Peering the vnet to existing hub vnet with Ansible/utilities server.
* Using a json source file for the VM definitions
* Custom tags (disable hyperthreading)
* Run "remote_exec" scripts for post OS config not possible with cloud-init

ToDo -

* Document key template code that is poorly documented in general.
* Create map object(list) for the VM configs
* Use existing NSGs
* Add Azure Arc agent

Need to document steps better  
  
#### Code documentation - In Progress

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
* Terraform documenmtation
