### Learn to use the Terraform Azure AD provider

I maintain a Tenant/Subscription for test and development amd frequently need to add/remove other colleagues so they can access resources. To make that easier I created this simple Terraform module to create and maintain a list of users stored in a csv file.  
This version assumes the existence of an Azure AD group with the assigned role of "Subscription Contributor" so you can automatically add a user and allow them access tyo the default Subscription.

- AD Group = "Subscription Administrators"

___

#### Sources

- [Tutorial - Manage Azure Active Directory (AD) Users and Groups](https://learn.hashicorp.com/tutorials/terraform/azure-ad)
- [Azure AD Provider](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/domains)
- [Azure RM Proiver](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

___

#### Notes

CSV File format:
sub_admin is a true/false toggle to add the user as a member of the Subscription Admin Group

```text
first_name,last_name,department,job_title,company_name,enabled,sub_admin
Test,User,Administration,GuestAdmin,Terraform_Managed,true,false
```

Get the group ID

```terraform
data "azuread_group" "subscription_contributors" {
  display_name = "Subscription Admins"
}
```

Add/remove the users to Subscription Admins

```terraform
resource "azuread_group_member" "sub_admins" {
  # Loop through users and find admins
  for_each = { for user in local.users : user.first_name => user if user.sub_admin =="true"}
  
  # Assign to Group
  group_object_id  = data.azuread_group.subscription_contributors.id
  member_object_id = azuread_user.users[each.key].id

}
```

___
  
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
