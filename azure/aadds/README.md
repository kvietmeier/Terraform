### Create an Azure Active Directory Domain Services Instance

From: [AADS Terraform Registry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/active_directory_domain_service)

The docs are incomplete - you need to add API Permissions to the Serice Principle - See:

<https://github.com/hashicorp/terraform-provider-azuread/issues/657>
<https://github.com/hashicorp/terraform-provider-azuread/blob/main/docs/guides/service_principal_configuration.md>
<https://github.com/hashicorp/terraform-provider-azuread/blob/main/docs/guides/microsoft-graph.md>

And the Service Principle must have GA permissions in the Tenant:
<https://docs.microsoft.com/en-us/azure/active-directory-domain-services/template-create-instance>

Important:

- You need global administrator privileges in your Azure AD tenant to enable Azure AD DS.
- You need Contributor privileges in your Azure subscription to create the required Azure AD DS resources.

#### Authors

- **Karl Vietmeier**

#### License

This project is licensed under the Apache License - see the [LICENSE.md](../LICENSE.md) file for details

#### Acknowledgments

- None so far other than the many good examples out there.
