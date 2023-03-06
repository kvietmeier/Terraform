### Azure Virtual Desktop Projects

This repo/folder holds code related to standing up AVD infra using Terraform.

Nothing is currently functional - just getting started (03/23)

#### Notes

To make my code more portable across Tenants/Subscriptions I'm using the TF Environment variables set in the PowerShell profile:  

TBD - will add doc references etc. here.

* [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
* [Terraform AzureAD Provider](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs)
* [MSLearn HowTo for AVD HostPool w/Terraform](https://learn.microsoft.com/en-us/azure/developer/terraform/configure-azure-virtual-desktop)
* [MSLearn HowTo for AVD Session Host w/Terraform](https://learn.microsoft.com/en-us/azure/developer/terraform/create-avd-session-host)
* [MSLearn AVD Prerequisites](https://learn.microsoft.com/en-us/azure/virtual-desktop/prerequisites)

Creation of a complete, functional AVD infrastructure with Terraform is a several step process:

* Establish prereqs (will you use existing AD/AAD services?)
* Configure AD if required
* Create Host Pool
* Create session hosts and join a domain

The biggest challenge standing up something from scratch you will have is the last step - the Authentication and domain join requirements:

* [AVD Identity Requirements](https://learn.microsoft.com/en-us/azure/virtual-desktop/prerequisites#identity)

#### Author/s

* **Karl Vietmeier**

#### License

This project is licensed under the Apache License - see the [LICENSE.md](../../LICENSE.md) file for details

#### Acknowledgments

* Marc Wolfson - AVD GBB
