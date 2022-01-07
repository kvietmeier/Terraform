### Terraform Projects

Terraform projects. Only the Azure folder is currently under active development.


#### Installing

[Hashicorp Learn Install Tutorial](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/certification-associate-tutorials)


#### Notes

**Terraform commands:**<br>
Really good cheat sheet<br>
https://acloudguru.com/blog/engineering/the-ultimate-terraform-cheatsheet


Run and over-ride locks<br>
```terraform destroy -lock=false --auto-approve```
```terraform apply -lock=false --auto-approve```

Run with a .tfvars file<br>
```terraform apply -var-file=".\MultiLinuxVM-vars.tfvars"```<br>
```terraform destroy -var-file=".\MultiLinuxVM-vars.tfvars"```<br>


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