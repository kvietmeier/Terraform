## VAST Data Terraform Template: Views, Policies & Block Storage

This repository is Terraform template for Views, View Policies, and Block Storage. It contains the complete schema definition cross referenced with the default settings.
It is not intended for use "as is" it is designed as a template and reference.  

---

## Table of Contents

- **View Policies** (`vastdata_view_policy`): Permission rules, audit settings, and security flavors for NFS, SMB, and S3 protocols.
- **Views** (`vastdata_view`): File exports, buckets, and shares mapped to specific paths and policies.
- **Block Hosts** (`vastdata_block_host`): SAN client host definitions and initiator mappings (iSCSI IQNs, FC WWPNs, NVMe NQNs).
- **Block Host Mappings** (`vastdata_block_host_mapping`): LUN attachments linking block hosts to VAST volumes.

---

### Architecture & Code Structure

The project is structured into 4 primary Terraform files:

```text
├── README.md
├── views.provider.tf
├── views.main.tf          # Core Terraform resource blocks and dynamic linkages
├── views.variables.tf     # Typed schema definitions for all parameters
└── views.auto.tfvars      # Environment-specific values and default parameters
```

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
