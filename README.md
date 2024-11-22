### Terraform Projects

Terraform projects - recently added GCP.

#### Installing Terraform

[Hashicorp Learn Install Tutorial](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/certification-associate-tutorials)

* InstallUpgradeTerraform.ps1 is a small PS script I wrote to upgrade/install the Terraform binary

* Terraform can now be installed and maintained with winget
  
  ```powershell
  KV C:\Users\karl.vietmeier\repos> winget list terraform
  Name                Id                  Version Available Source
  ----------------------------------------------------------------
  Hashicorp Terraform Hashicorp.Terraform 1.9.5   1.9.8     winget
  ```

  Upgrade it
  
  ```powershell
  KV C:\Users\karl.vietmeier\repos> winget update terraform
  Found Hashicorp Terraform [Hashicorp.Terraform] Version 1.9.8
  This application is licensed to you by its owner.
  Microsoft is not responsible for, nor does it grant any licenses to, third-party packages.
  Downloading https://releases.hashicorp.com/terraform/1.9.8/terraform_1.9.8_windows_amd64.zip
  ██████████████████████████████  26.0 MB / 26.0 MB
  Successfully verified installer hash
  Extracting archive...
  Successfully extracted archive
  Starting package install...
  Command line alias added: "terraform"
  Successfully installed

  KV C:\Users\karl.vietmeier\repos> winget list terraform
  Name                Id                  Version Source
  -------------------------------------------------------
  Hashicorp Terraform Hashicorp.Terraform 1.9.8   winget
  
  KV C:\Users\karl.vietmeier\repos>
  ```

---

#### Directories

```text
├── scripts
│   │── InstallUpgradeTerraform.ps1
|
├── azure
│   │── AKS          (AKS cluster projects)
│   │── AVD          (AVD projects - placeholder)
│   │── CoreInfra    (Production modules to manage my infrastructure)
│   │── samples      (Non-functional code samples)
│   │── secrets      (certs, cloud-init files, etc in .gitignore)
│   │── templates    (templates for new projects)
│   │── testing      (Primary working Directory)
│   │── VMs          (What it says)
│   |── README.md
|
├── gcp
│   │── CoreInfra    (Production modules to manage my infrastructure)
│   │── scripts      (Misc scripts and config files)
│   │── templates    (templates for new projects)
│   │── testing      (Primary working Directory for new projects)
│   |── README.md
|
├── LICENSE.md
└── README.md
```

---

#### GCP Quirks

* Linux images provided on GCP do not have cloud-init installed!
  You will need to use the metadata block in the VM resource to run a startup scrupt to install it
  
  This code runs a small script to install cloud-init and reboot then adds SSH keys to authorized_keys, enables serial port access and then adds the cloud-init.yml to configure the system.

  ```terraform
  metadata = {
    # Install cloud-init if not available yet
    startup-script = <<-EOT
    #!/bin/bash
    command -v cloud-init &>/dev/null || (dnf install -y cloud-init && reboot)
    EOT
    
    ssh-keys           = "${var.ssh_user}:${local.ssh_key_content}"
    serial-port-enable = true # Enable serial port access for debugging
    user-data          = "${data.cloudinit_config.system_setup.rendered}"
  }
  ```

---

#### Terraform Notes

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
**PowerShell Alias/Shortcuts**
So you don't have to keep calling out the non-standard tfvars file.

```powershell
function tfapply {
  # Run an apply using the tfvars file in the current folder
  $VarFile=(Get-ChildItem -Path .  -Recurse -Filter "*.tfvars")
  terraform apply --auto-approve -var-file="$VarFile"
}
```

```powershell
function tfdestroy {
  # Run a destroy using the tfvars file in the current folder 
  $VarFile=(Get-ChildItem -Path .  -Recurse -Filter "*.tfvars")
  terraform destroy --auto-approve -var-file="$VarFile"
}
```

```powershell
function tfshow {
  # 
  terraform show
}
```

---
  
#### My code is Built With

* [Visual Studio Code](https://code.visualstudio.com/) - Editor
* [Terraform](https://www.terraform.io/) - Terraform

#### All run under PowerShell on Windows 11

* [Windows Terminal](https://docs.microsoft.com/en-us/windows/terminal/) - Console

#### Authors

* **Karl Vietmeier**

#### License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

#### Acknowledgments

* None so far other than the many good examples out there.
