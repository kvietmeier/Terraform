### Create an Azure Active Directory Domain Services Instance

Why?  Because you need it for Azure Virtual Desktop

Sources:
[Azure AD Provider](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs)
[AADS Terraform Registry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/active_directory_domain_service)

**Some Notes:**
The docs are incomplete - you need to add API Permissions to the Serice Principle - See:  
[GitHub Issue 657](https://github.com/hashicorp/terraform-provider-azuread/issues/657)  
[Service Principle Config](https://github.com/hashicorp/terraform-provider-azuread/blob/main/docs/guides/service_principal_configuration.md)  
[MSFT Graph Guide](https://github.com/hashicorp/terraform-provider-azuread/blob/main/docs/guides/microsoft-graph.md)  

The Service Principle must have GA permissions in the Tenant:  
<https://docs.microsoft.com/en-us/azure/active-directory-domain-services/template-create-instance>

- It can take an hour to complete the creation

**Important:**

- You need global administrator privileges in your Azure AD tenant to enable Azure AD DS.
- You need Contributor privileges in your Azure subscription to create the required Azure AD DS resources.

#### Authors

- **Karl Vietmeier**

#### License

This project is licensed under the Apache License - see the [LICENSE.md](../../LICENSE.md) file for details

#### Acknowledgments

- None so far
