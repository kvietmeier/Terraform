### Create Azure Storage 

Code in this module is attempting to create Storage Accounts and add shares and blobs to them.

I'm also expirementing with using "count" and "for_each" to explore the differences between maps and complex object lists.

#### Notes

Terraform Documentation

* [Storage Account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account)
* [Storage Share](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_share)
* [Storage Blob](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_blob)

Resource block to create the Storage Accounts:

```terraform
# Create the Storage Account/s
resource "azurerm_storage_account" "storage_acct" {
  #count                    = length(var.storage_account_configs)

  # Use for_each
  for_each                 = { for each in var.storage_account_configs : each.name => each }
  location                 = var.resource_group_config[0].region
  name                     = "${each.value.name}${random_id.randomID.dec}"
  resource_group_name      = azurerm_resource_group.storage-rg[0].name
  account_kind             = each.value.acct_kind
  account_tier             = each.value.account_tier
  access_tier              = each.value.access_temp
  account_replication_type = each.value.replication
}
```

Object(list) definition

```terraform
variable "storage_account_configs" {
  description = "Resource Group"
  type = list(
    object(
      { name         = string,
        acct_kind    = string,
        account_tier = string,
        access_temp  = string,
        replication  = string
      }
    )
  )
}
```

When referencing the Storage Account objects in other resource blocks you need to use the value of the "name" key as the index

```terraform
storage_account_name = azurerm_storage_account.storage_acct["files"].name
```
  
#### My code is Built With

* [Visual Studio Code](https://code.visualstudio.com/) - Editor
* [Terraform](https://www.terraform.io/) - Terraform
* [Azure](portal.azure.com) - Azure Portal

#### All run under PowerShell on Windows 10

* [Windows Terminal](https://docs.microsoft.com/en-us/windows/terminal/) - Console

#### Author/s

* **Karl Vietmeier**

#### License

This project is licensed under the Apache License - see the [LICENSE.md](LICENSE.md) file for details

#### Acknowledgments

* None so far other than the many good examples out there.
