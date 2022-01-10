### Terraform Projects

Terraform projects. Only the Azure folder is currently under active development.


#### Installing

[Hashicorp Learn Install Tutorial](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/certification-associate-tutorials)


#### Notes

**Terraform commands:**<br>
A good cheat sheet I ran across<br>
https://acloudguru.com/blog/engineering/the-ultimate-terraform-cheatsheet

Apply/destroy without prompting<br>
```terraform destroy --auto-approve```<br>
```terraform apply --auto-approve```

Run and over-ride locks<br>
```terraform destroy -lock=false --auto-approve```<br>
```terraform apply -lock=false --auto-approve```

Run with a .tfvars file<br>
```terraform apply -var-file=".\MultiLinuxVM-vars.tfvars"```<br>
```terraform destroy -var-file=".\MultiLinuxVM-vars.tfvars"```

Put it all together<br>
```terraform apply --auto-approve -var-file=".\<fname>.tfvars"```<br>
```terraform destroy --auto-approve -var-file=".\<fname>.tfvars"```



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