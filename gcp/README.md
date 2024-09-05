### Terraform for GCP Projects

Terraform templates for creating infrastructure in Azure.

#### Documentation Links

- [Terraform on GCP](https://cloud.google.com/docs/terraform)
- [HashiLearn - GCP](https://developer.hashicorp.com/terraform/tutorials/gcp-get-started)
- [Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Google Module Registry](https://registry.terraform.io/providers/hashicorp/google/latest)

#### Misc Notes

To make my code more portable across Tenants/Subscriptions I'm using the TF Environment variables set in the PowerShell profile:  

Source a "secrets file" for the variables:

```powershell
. '<drive>:\.hideme\somesecretstuff.ps1'
```

Set the variables for GCP (need settings):

```powershell
$env:[]
$env:[]
```
  
#### My code is Built With

- [Visual Studio Code](https://code.visualstudio.com/) - Editor
- [Terraform](https://www.terraform.io/) - Terraform

#### All run under PowerShell on Windows 10/11

- [Use Windows Terminal Console](https://docs.microsoft.com/en-us/windows/terminal/)

#### Author/s

- **Karl Vietmeier**

#### License

This project is licensed under the Apache License - see the [LICENSE.md](LICENSE.md) file for details

#### Acknowledgments

- None so far other than the many good examples out there.
