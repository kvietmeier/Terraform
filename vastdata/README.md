# vastdata/

Terraform examples and templates for the [VAST Data provider](https://registry.terraform.io/providers/vast-data/vastdata/latest/docs).

## Layout

```text
vastdata/
├── provider/                  # Portable provider.tf pattern (env-driven auth)
├── simple_query/              # Auth / connectivity smoke test (read default tenant)
├── basic_cluster/             # Demo/POC baseline cluster config
├── complete_cluster_config/   # Full end-to-end cluster config (VIP, DNS, AD, …)
├── lab_setup/                 # Multi-cluster lab orchestrator (Polaris / VoC style)
├── createviews/               # NFS/SMB views + policies against an existing VIP pool
├── view_template/             # Reference schema for views, policies, and block storage
├── block_volumes/             # Block subsystem views / Windows block examples
├── protected_path/            # Protected path / multi-cluster examples
├── policies/                  # S3 / view-policy JSON samples and dumps
└── templates/                 # Shared variable stubs and S3 policy JSON examples
```

| Directory | Purpose |
|-----------|---------|
| [`provider/`](provider/) | Drop-in / symlinkable `vastdata` provider using `TF_VAR_*` / env auth |
| [`simple_query/`](simple_query/) | Lightweight login test before larger applies |
| [`basic_cluster/`](basic_cluster/) | POC baseline: tenants, users, NFS/S3 views and policies |
| [`complete_cluster_config/`](complete_cluster_config/) | Full cluster from scratch (VIP pools, DNS, AD, keys, …) |
| [`lab_setup/`](lab_setup/) | Scripted multi-cluster lab setup (`labclusters_setup.sh`) |
| [`createviews/`](createviews/) | Create views/policies on an existing cluster/VIP pool |
| [`view_template/`](view_template/) | Documented resource template (not meant to apply as-is) |
| [`block_volumes/`](block_volumes/) | Block view / policy examples |
| [`protected_path/`](protected_path/) | Protected path resources across clusters |
| [`policies/`](policies/) | Policy JSON samples and setting dumps |
| [`templates/`](templates/) | Reusable variables / S3 policy JSON snippets |

## Prerequisites

- Terraform installed
- Network access to the VAST VMS
- [VAST Data Terraform provider](https://registry.terraform.io/providers/vast-data/vastdata/latest/docs)

## Authentication

Set VMS connection details as environment variables (preferred over committing secrets).

Linux / macOS:

```bash
export TF_VAR_vast_host="192.168.1.100"
export TF_VAR_vast_username="admin"
export TF_VAR_vast_password="YourActualVMSPasswordHere"
```

Windows PowerShell:

```powershell
$env:TF_VAR_vast_host = "192.168.1.100"
$env:TF_VAR_vast_username = "admin"
$env:TF_VAR_vast_password = "YourActualVMSPasswordHere"
```

Some stacks also honor native provider env vars (see [`provider/README.md`](provider/README.md)).

## Typical workflow

1. Start with [`simple_query/`](simple_query/) to verify credentials.
2. Use [`basic_cluster/`](basic_cluster/) or [`complete_cluster_config/`](complete_cluster_config/) for a full POC setup.
3. Use [`createviews/`](createviews/) or [`block_volumes/`](block_volumes/) against an existing cluster.
4. For many Polaris/VoC lab clusters, use [`lab_setup/`](lab_setup/).

```bash
cd vastdata/simple_query
terraform init
terraform plan
terraform apply
```

## Notes

- Prefer `*.auto.tfvars` / env vars over committing real passwords.
- `view_template/` and much of `templates/` / `policies/` are **reference material**, not turnkey stacks.
- Repo-wide Terraform shortcuts (`tfapply`, etc.) live in the parent [README.md](../README.md); bash helpers under [`../scripts/`](../scripts/).
- Prefer the paths in this tree for VAST provider examples; treat older duplicate copies elsewhere as legacy.

## Author

**Karl Vietmeier**

## Acknowledgments

Josh Wentzell at VAST for getting this started and answering many basic questions.
