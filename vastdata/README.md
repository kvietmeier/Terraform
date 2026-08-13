## VAST Data Terraform 

---

### Usage

You will need to set the cluster VMS information as environment variables.

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

---