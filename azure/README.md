### Terraform Azure Templates

Terraform templates for creating infrastructure in Azure.

#### Documentation Links

- [Terraform on Azure](https://docs.microsoft.com/en-us/azure/developer/terraform/)
- [HashiLearn - Azure](https://learn.hashicorp.com/collections/terraform/azure-get-started)
- [AzureRM Registry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

#### Misc Notes

To make my code more portable across Tenants/Subscriptions I'm using the TF Environment variables set in the PowerShell profile:  

Source a "secrets file" for the variables:

```powershell
. '<drive>:\.hideme\somesecretstuff.ps1'
```

Set the variables:

```powershell
$env:ARM_TENANT_ID       ="$TFM_TenantID"
$env:ARM_SUBSCRIPTION_ID ="$TFM_SubID"
$env:ARM_CLIENT_ID       ="$TFM_AppID"
$env:ARM_CLIENT_SECRET   ="$TFM_AppSecret"
```
  
#### My code is Built With

- [Visual Studio Code](https://code.visualstudio.com/) - Editor
- [Terraform](https://www.terraform.io/) - Terraform
- [Azure](portal.azure.com) - Azure Portal

#### All run under PowerShell on Windows 10/11

- [Use Windows Terminal Console](https://docs.microsoft.com/en-us/windows/terminal/)

#### Author/s

- **Karl Vietmeier**

#### License

This project is licensed under the Apache License - see the [LICENSE.md](../LICENSE.md) file for details

#### Acknowledgments

- None so far other than the many good examples out there.
