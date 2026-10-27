# Terraform Projects

Multi-cloud Terraform lab and POC stacks for AWS, Azure, GCP, and OCI — plus scrubbed **VAST Data provider** working examples under [`vastdata/`](vastdata/).

Stacks are organized by cloud (or provider). Each leaf folder is typically a self-contained root module you can `init` / `plan` / `apply`. Shared Linux/Windows bootstrap lives under [`scripts/`](scripts/).

Live VAST lab stacks (real hosts, `setup_lab`, VoC wrappers) stay on GitLab [`karlv/tools`](https://git.vastdata.com/karlv/tools) → `terraform/vast/`. Real `*.tfvars` stay local / in private [`personal/terraform-tfvars`](https://github.com/kvietmeier/personal).

## Where things live (three tiers)

| Need | Place |
|------|-------|
| Karl-only Jira / proposal drafts | GitHub private [`personal`](https://github.com/kvietmeier/personal) → `staging/` |
| Company-shareable runbooks / RAs | GitLab [`projects-docs`](https://git.vastdata.com/karlv/projects-docs) |
| Live VAST provider lab TF | GitLab [`tools`](https://git.vastdata.com/karlv/tools) → `terraform/vast/` |
| VoC cloud modules | GitLab [`vastoncloud`](https://git.vastdata.com/karlv/vastoncloud) |
| **This repo** — scrubbed cloud + VAST examples | Public GitHub (`vastdata/`, `aws/`, `azure/`, `gcp/`, `oci/`) |
| Azure helper scripts | GitHub [`cloud-tools`](https://github.com/kvietmeier/cloud-tools) |

## Start here (basics)

| Example | Path |
|---------|------|
| VAST auth smoke test | [`vastdata/simple_query/`](vastdata/simple_query/) |
| VAST POC baseline (views/users) | [`vastdata/basic_cluster/`](vastdata/basic_cluster/) |
| GCP project roll-up | [`gcp/configure-project/`](gcp/configure-project/) |
| AWS EC2 Linux clients | [`aws/ec2/linux_clients/`](aws/ec2/linux_clients/) |
| Azure Linux VMs | [`azure/VMs/`](azure/VMs/) |
| Shared cloud-init / Windows | [`scripts/`](scripts/) |

Copy any `*.tfvars.example` → `*.tfvars` (gitignored) before apply.

## Quick start

1. [Install Terraform](https://developer.hashicorp.com/terraform/install).
2. Authenticate to the target cloud or VAST VMS (`TF_VAR_vast_*` for provider examples).
3. Pick a stack directory, copy/edit tfvars examples, then:

```bash
cd <cloud-or-vastdata>/<stack>
terraform init
terraform plan
terraform apply
```

## Repository layout

```text
.
├── aws/                 # AWS stacks
├── azure/               # Azure: CoreInfra, VMs, AKS, AVD, templates
├── gcp/                 # GCP: CoreInfra, configure-project, VMs, GKE, TPUs
├── oci/                 # Oracle Cloud stacks
├── vastdata/            # Scrubbed VAST Data provider working examples
├── scripts/             # Shared helpers — see scripts/README.md
├── LICENSE.md
└── README.md
```

| Area | What it is | Start here |
|------|------------|------------|
| [`vastdata/`](vastdata/) | VAST provider examples (auth, views, block, full config) | [`vastdata/README.md`](vastdata/README.md) |
| [`azure/`](azure/) | Networks, identity, VMs, AKS, AVD | [`azure/README.md`](azure/README.md) |
| [`gcp/`](gcp/) | VPCs/firewalls/DNS, roll-up project module, VMs, GKE | [`gcp/README.md`](gcp/README.md) |
| [`scripts/`](scripts/) | Cloud-init, Windows specialize | [`scripts/README.md`](scripts/README.md) |
| [`aws/`](aws/) | EC2 / IAM patterns | `aws/` |
| [`oci/`](oci/) | OCI templates | `oci/` |

## Conventions

- **One stack per folder** — independent root module.
- **Secrets stay local** — untracked `*.tfvars` / env vars; commit `*.tfvars.example` only.
- **Backup real tfvars** — `scripts/sync-tfvars-personal.sh` → `~/github/personal/terraform-tfvars/`.
- **Examples stay public** — placeholders only (`192.168.1.100`, `lab.example.com`, `gcp-project-id`).

## Author

**Karl Vietmeier**

## License

Apache 2.0 — see [LICENSE.md](LICENSE.md).
