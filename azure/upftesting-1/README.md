### Create a multi-vm enviroment with 2 NICs per VM

The goal is to build a platform for testing Telco related workloads leveraging:
* Proximity Placement Groups
* Network Security Groups
* 2 NICs per VM - one with a Publlic IP, one internal Only
* Accelerated Networking
* Bootdiags for Serial Console access
* cloud-init for OS setup

ToDo - 
* Configure peering to existing hub vnet with Ansible server.
* Refactor to be module based
* Document key template code that is poorly documented in general.

Need to document steps<br>
.<br>

#### Code documentation - In Progress

To make my code more portable across dseveral; Tenants/Subscriptions I'm using the TF Environment variables set in my PowerShell profile:<br>
Source a "secrets file" for the variables:
```
. '<drive>:\.hideme\somesecretstuff.ps1'
```

Set the variables:
```
$env:ARM_TENANT_ID       ="$TFM_TenantID"
$env:ARM_SUBSCRIPTION_ID ="$TFM_SubID"
$env:ARM_CLIENT_ID       ="$TFM_AppID"
$env:ARM_CLIENT_SECRET   ="$TFM_AppSecret"
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
