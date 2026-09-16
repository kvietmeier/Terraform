# Terraform Projects

Terraform projects — recently added VAST Data.

## Installing Terraform

[Hashicorp Instructions](https://developer.hashicorp.com/terraform/install)

* `scripts/InstallUpgradeTerraForm.ps1` upgrades/installs the Terraform binary
* Terraform can also be installed and maintained with winget

```powershell
winget list terraform
winget update terraform
```

## Directories

```text
.
├── aws/                 # AWS stacks
├── azure/               # Azure stacks
├── gcp/                 # GCP stacks (+ configure-project)
├── oci/                 # OCI stacks
├── vastdata/            # VAST Data Terraform
├── scripts/             # Shared helpers (see scripts/README.md)
│   ├── cloud-init/      # Universal Linux lab bootstrap (all clouds)
│   ├── windows/         # Generic Windows sysprep / static-IP scripts
│   ├── gcp/             # GCP-only (gcloud listing, GCE AD metadata)
│   ├── azure/           # Azure-only (vms/, aks/)
│   └── aws/             # AWS-only helpers
├── LICENSE.md
└── README.md
```

## Terraform notes

### Commands

Apply/destroy without prompting:

```powershell
terraform destroy --auto-approve
terraform apply --auto-approve
```

Override locks:

```powershell
terraform destroy -lock=false --auto-approve
terraform apply -lock=false --auto-approve
```

Use a `.tfvars` file:

```powershell
terraform apply -var-file=".\MultiLinuxVM-vars.tfvars"
terraform destroy -var-file=".\MultiLinuxVM-vars.tfvars"
```

Combined:

```powershell
terraform apply --auto-approve -var-file=".\<fname>.tfvars"
terraform destroy --auto-approve -var-file=".\<fname>.tfvars"
```

### PowerShell shortcuts

So you don't have to keep calling out the non-standard tfvars file.

```powershell
function tfapply {
  $VarFile = (Get-ChildItem -Path . -Recurse -Filter "*.tfvars")
  terraform apply --auto-approve -var-file="$VarFile"
}

function tfdestroy {
  $VarFile = (Get-ChildItem -Path . -Recurse -Filter "*.tfvars")
  terraform destroy --auto-approve -var-file="$VarFile"
}

function tfshow {
  terraform show
}
```

## Built with

* [Visual Studio Code](https://code.visualstudio.com/)
* [Terraform](https://www.terraform.io/)
* [Windows Terminal](https://docs.microsoft.com/en-us/windows/terminal/) (PowerShell on Windows 11)

## Author

**Karl Vietmeier**

## License

MIT — see [LICENSE.md](LICENSE.md).
