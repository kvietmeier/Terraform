# Terraform Projects

Multi-cloud Terraform lab and POC stacks for AWS, Azure, GCP, and OCI, plus [VAST Data](https://www.vastdata.com/) cluster configuration examples.

Stacks are organized by cloud provider. Each leaf folder is typically a self-contained root module (`*.tf` + `*.tfvars`) you can `init` / `plan` / `apply` on its own. Shared Linux/Windows bootstrap lives under [`scripts/`](scripts/), not under each cloud.

## Quick start

1. [Install Terraform](https://developer.hashicorp.com/terraform/install) (or use `scripts/InstallUpgradeTerraForm.ps1` / `winget` on Windows).
2. Authenticate to the target cloud (see cloud sections below).
3. Pick a stack directory, copy/edit any `*.tfvars` / `*.tfvars.example`, then:

```bash
cd <cloud>/<area>/<stack>
terraform init
terraform plan
terraform apply
```

For VAST, start with [`vastdata/simple_query/`](vastdata/simple_query/) to verify credentials before larger applies.

## Repository layout

```text
.
├── aws/                 # AWS stacks (lighter footprint)
├── azure/               # Azure: CoreInfra, VMs, AKS, AVD, templates
├── gcp/                 # GCP: CoreInfra, configure-project, VMs, GKE, TPUs
├── oci/                 # Oracle Cloud stacks
├── vastdata/            # VAST Data provider examples (cluster / views / lab)
├── scripts/             # Shared helpers — see scripts/README.md
│   ├── cloud-init/      # Universal Linux lab bootstrap (all clouds)
│   ├── windows/         # Generic Windows sysprep / static-IP scripts
│   ├── gcp/             # GCP-only helpers
│   ├── azure/           # Azure-only (vms/, aks/)
│   └── aws/             # AWS-only helpers
├── LICENSE.md
└── README.md
```

| Area | What it is | Start here |
|------|------------|------------|
| [`azure/`](azure/) | Networks, identity, VMs, AKS, AVD | [`azure/README.md`](azure/README.md) |
| [`gcp/`](gcp/) | VPCs/firewalls/DNS, roll-up project module, VMs, GKE, TPUs | [`gcp/README.md`](gcp/README.md), [`gcp/configure-project/`](gcp/configure-project/) |
| [`vastdata/`](vastdata/) | VAST provider: auth smoke test → full cluster / lab / views | [`vastdata/README.md`](vastdata/README.md) |
| [`scripts/`](scripts/) | Cloud-init, Windows specialize, cloud-specific helpers | [`scripts/README.md`](scripts/README.md) |
| [`aws/`](aws/) | EC2 / basic auth / CloudFormation samples | `aws/` |
| [`oci/`](oci/) | OCI templates and multi-VM examples | `oci/` |

## By cloud

### Azure (`azure/`)

| Directory | Purpose |
|-----------|---------|
| [`CoreInfra/`](azure/CoreInfra/) | Shared infra: vNets, NSGs, AADDS, VPN GW, storage, user management |
| [`VMs/`](azure/VMs/) | Linux / Windows / multi-VM and benchmarking stacks |
| [`AKS/`](azure/AKS/) | AKS cluster examples and deploy helpers |
| [`AVD/`](azure/AVD/) | Azure Virtual Desktop experiments |
| [`templates/`](azure/templates/) | Reusable snippets / starter patterns |
| [`testing/`](azure/testing/) | Scratch / experimental modules |

Auth is usually via AzureRM env vars (`ARM_TENANT_ID`, `ARM_SUBSCRIPTION_ID`, `ARM_CLIENT_ID`, `ARM_CLIENT_SECRET`) loaded from a local secrets script — details in [`azure/README.md`](azure/README.md).

### GCP (`gcp/`)

| Directory | Purpose |
|-----------|---------|
| [`CoreInfra/`](gcp/CoreInfra/) | Production-style pieces: VPCs, firewalls, DNS, NAT, VPN, IAP, core VMs |
| [`configure-project/`](gcp/configure-project/) | **Roll-up** of CoreInfra into one apply (feature flags) — preferred for a full project |
| [`VMs/`](gcp/VMs/) | Standalone VM patterns (multi-VM, proxy, Windows, images, …) |
| [`GKE/`](gcp/GKE/) | GKE clusters and sample Kubernetes apps |
| [`tpus/`](gcp/tpus/) | TPU node / discovery experiments |
| [`templates/`](gcp/templates/), [`testing/`](gcp/testing/) | Starters and scratch |

Many Linux images on GCP lack cloud-init; VM stacks often install it via `startup-script` metadata. See [`gcp/README.md`](gcp/README.md).

### VAST Data (`vastdata/`)

Provider examples for configuring VAST clusters (tenants, views, VIP pools, AD, lab orchestration). Prefer env-based auth (`TF_VAR_vast_*`). Full map and workflow: [`vastdata/README.md`](vastdata/README.md).

### AWS / OCI

Smaller collections under [`aws/`](aws/) (EC2, basic auth, CloudFormation) and [`oci/`](oci/) (templates, multi-VM). Use the same per-folder apply pattern as the other clouds.

## Conventions

- **One stack per folder** — treat each leaf with its own `.tf` files as an independent root module.
- **Secrets stay local** — use env vars or untracked `*.auto.tfvars` / private tfvars; do not commit passwords or keys.
- **Shared bootstrap** — Linux user-data: [`scripts/cloud-init/`](scripts/cloud-init/) (`cloud-init-universal.yaml` day-to-day). Windows: [`scripts/windows/`](scripts/windows/). Do not add new scripts under stale stubs like `gcp/scripts` or `azure/VMs/scripts` — those point at `scripts/`.
- **`templates/`** folders are reference/starters; not every file is meant to apply as-is.

## Installing Terraform

[HashiCorp install docs](https://developer.hashicorp.com/terraform/install)

- `scripts/InstallUpgradeTerraForm.ps1` — install/upgrade the binary on Windows
- Or with winget:

```powershell
winget list terraform
winget upgrade terraform
```

## Terraform notes

### Common commands

```bash
terraform apply -auto-approve
terraform destroy -auto-approve

# Override state lock (use carefully)
terraform apply -lock=false -auto-approve

# Explicit tfvars
terraform apply -var-file="./MultiLinuxVM-vars.tfvars"
```

### PowerShell shortcuts

Avoid repeating a non-default tfvars path:

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

- [Visual Studio Code](https://code.visualstudio.com/) / Cursor
- [Terraform](https://www.terraform.io/)
- [Windows Terminal](https://docs.microsoft.com/en-us/windows/terminal/) (PowerShell on Windows 11)

## Author

**Karl Vietmeier**

## License

Apache 2.0 — see [LICENSE.md](LICENSE.md).
