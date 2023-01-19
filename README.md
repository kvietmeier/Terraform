### Terraform Projects

Terraform projects. Only the Azure folder is currently under active development.

#### Installing

[Hashicorp Learn Install Tutorial](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/certification-associate-tutorials)

#### Notes

Directories

```text
├── azure
│   │── AKS          (AKS cluster projects)
│   │── CoreInfra    (Production modules to manage my infrastructure)
│   │── VMs          (What it says)
│   │── samples      (Non-functional code samples)
│   │── secrets      (in .gitignore)
│   │── templates    (templates for new projects)
│   │── testing      (Primary working Directory)
│   |── README.md
├── LICENSE.md
└── README.md
```


**Terraform commands:**  
A good cheat sheet I ran across  
<https://acloudguru.com/blog/engineering/the-ultimate-terraform-cheatsheet>

Apply/destroy without prompting  

```powershell
terraform destroy --auto-approve
terraform apply --auto-approve
```

Run and over-ride locks  

```powershell
terraform destroy -lock=false --auto-approve
terraform apply -lock=false --auto-approve
```

Run with a .tfvars file  

```powershell
terraform apply -var-file=".\MultiLinuxVM-vars.tfvars"
terraform destroy -var-file=".\MultiLinuxVM-vars.tfvars"
```

Put it all together  

```powershell
terraform apply --auto-approve -var-file=".\<fname>.tfvars"
terraform destroy --auto-approve -var-file=".\<fname>.tfvars"
```

---
  
#### My code is Built With

* [Visual Studio Code](https://code.visualstudio.com/) - Editor
* [Terraform](https://www.terraform.io/) - Terraform
* [Azure](portal.azure.com) - Azure Portal

#### All run under PowerShell on Windows 10

* [Windows Terminal](https://docs.microsoft.com/en-us/windows/terminal/) - Console

#### Authors

* **Karl Vietmeier**

#### License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

#### Acknowledgments

* None so far other than the many good examples out there.
