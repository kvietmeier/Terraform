### Learn to use the Terraform Azure AD provider

Create and maintain a list of users stored in a csv file.

#### Sources

- [Tutorial - Manage Azure Active Directory (AD) Users and Groups](https://learn.hashicorp.com/tutorials/terraform/azure-ad)
- [Azure AD Provider](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/domains)
- [Azure RM Proiver](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

#### Notes

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

#### All run under PowerShell on Windows 11

- [Windows Terminal](https://docs.microsoft.com/en-us/windows/terminal/) - Console

#### Author/s

- **Karl Vietmeier**

#### License

This project is licensed under the Apache License - see the [LICENSE.md](LICENSE.md) file for details

#### Acknowledgments

- None so far other than the many good examples out there.
