# Terraform Projects

### Directories (subject to change)

```text
├── README.md
├── basic_cluster
├── cluster_full
├── createviews
├── lab_setup
├── policies
├── protected_path
├── simple_query
├── templates
└── view_template

```

---

#### Terraform Notes

**Terraform commands:**  

Apply/destroy without prompting  

```shell
terraform destroy --auto-approve
terraform apply --auto-approve
```

Run and over-ride locks  

```shell
terraform destroy -lock=false --auto-approve
terraform apply -lock=false --auto-approve
```

Run with a non-standard .tfvars file  

```shell
terraform apply -var-file=".\MultiLinuxVM-vars.tfvars"
terraform destroy -var-file=".\MultiLinuxVM-vars.tfvars"
```

**Put it all together**

```shell
terraform apply --auto-approve -var-file=".\<fname>.tfvars"
terraform destroy --auto-approve -var-file=".\<fname>.tfvars"
```

---

### Aliases/Shortcuts

So you don't have to keep calling out the non-standard tfvars file.

```shell
tfapply() {
    shopt -s nullglob
    local var_files=(*.tfvars)
    shopt -u nullglob
    [[ ${#var_files[@]} -eq 0 ]] && { echo "No .tfvars files found."; return 1; }
    terraform apply --auto-approve "${var_files[@]/#/-var-file=}"
}
```

```shell
tfdestroy() {
    shopt -s nullglob
    local var_files=(*.tfvars)
    shopt -u nullglob
    [[ ${#var_files[@]} -eq 0 ]] && { echo "No .tfvars files found."; return 1; }
    terraform destroy --auto-approve "${var_files[@]/#/-var-file=}"
}
```

```shell
tfplan() {
    shopt -s nullglob
    local var_files=(*.tfvars)
    shopt -u nullglob
    [[ ${#var_files[@]} -eq 0 ]] && { echo "No .tfvars files found."; return 1; }
    terraform plan "${var_files[@]/#/-var-file=}"
}
```

```shell
tfshow() { terraform output; }
tfinit() { terraform init; }
```

---

Cleanup Functions -

```shell
tfclean() {
    echo "Removing .terraform dirs, tfstate files, and backups..."
    find . -type d -name ".terraform" -exec rm -rf {} +
    rm -f terraform.tfstate terraform.tfstate.backup
    echo "Reinitializing Terraform..."
    terraform init
}
```

```shell
tfclstate() {
    echo "Removing tfstate files and backups (keeping .terraform)..."
    rm -f terraform.tfstate terraform.tfstate.backup
    terraform init
}
```

---
---
  
#### My code is Built With

* [Visual Studio Code](https://code.visualstudio.com/) - Editor
* [Terraform](https://www.terraform.io/) - Terraform

#### Authors

* **Karl Vietmeier**

#### License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

#### Acknowledgments

* None so far other than the many good examples out there.
