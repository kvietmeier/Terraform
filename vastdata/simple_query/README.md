# Simple Authentication Test

Lightweight Terraform configuration used to verify authentication with a VAST Data cluster. This script performs a basic read operation by retrieving metadata for the default tenant, allowing you to:

- Confirm provider credentials and connectivity
- Validate SSL and host configuration
- Troubleshoot access issues before applying full deployments

---

## Usage

### You will need to set the cluster VMS information as environment variables.**

Linux:

```bash
export TF_VAR_vast_host="192.168.1.100"
export TF_VAR_vast_username="admin"
export TF_VAR_vast_password="YourActualVMSPasswordHere"
```

Windows:

```powershell
$env:TF_VAR_vast_host = "192.168.1.100"
$env:TF_VAR_vast_username = "admin"
$env:TF_VAR_vast_password = "YourActualVMSPasswordHere"
```

### Using <>.auto.tfvars**

You can run `terraform apply`without specifying the non-standard tfvars filename.


