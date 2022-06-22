### AKS Cluster

Using the published Hashicorp Terraform AKS module

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
  
#### Author/s

* **Karl Vietmeier**

#### License

This project is licensed under the Apache License - see the [LICENSE.md](LICENSE.md) file for details

#### Acknowledgments

* [https://registry.terraform.io/modules/Azure/aks/azurerm/latest](Terraform AKS Module)
