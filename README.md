# Terraform Projects

Multi-cloud Terraform lab and POC stacks for AWS, Azure, GCP, and OCI — plus
**VAST Data provider** examples under [`vastdata/`](vastdata/).

Each leaf folder is typically a self-contained root module you can
`init` / `plan` / `apply`. Shared Linux/Windows bootstrap lives under
[`scripts/`](scripts/).

## Start here

| Example | Path |
|---------|------|
| VAST auth smoke test | [`vastdata/simple_query/`](vastdata/simple_query/) |
| VAST POC baseline (views/users) | [`vastdata/basic_cluster/`](vastdata/basic_cluster/) |
| GCP project roll-up | [`gcp/configure-project/`](gcp/configure-project/) |
| AWS Linux clients (`multi_vm`) | [`aws/ec2/multi_vm/`](aws/ec2/multi_vm/) |
| GCP Linux clients (`multi_vm`) | [`gcp/VMs/multi_vm/`](gcp/VMs/multi_vm/) |
| Azure Linux clients (`multi_vm`) | [`azure/VMs/multi_vm/`](azure/VMs/multi_vm/) |
| Shared cloud-init / Windows | [`scripts/`](scripts/) |

## Linux POC clients → day-2 Ansible

Terraform + [`scripts/cloud-init/`](scripts/cloud-init/) births tools-ready VMs (user **`strata`**, NFS *packages* only).
Install the VAST NFS **kernel driver** and lab polish with
[kvietmeier/ansible](https://github.com/kvietmeier/ansible):

```bash
ansible-playbook -i inventory.ini site.yml --tags client,install_driver
```

Same naming on every cloud: `multi_vm` / `multi_vm_map`, prefix `kv-`, optional mineral `vm_names`
(`copper`, `lead`, `zinc`, `moly`, `silver`, `gold`).

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
├── aws/                 # AWS stacks (EC2, IAM patterns)
├── azure/               # Azure: CoreInfra, VMs, AKS, AVD, templates
├── gcp/                 # GCP: CoreInfra, configure-project, VMs, GKE, TPU
├── oci/                 # Oracle Cloud stacks
├── vastdata/            # VAST Data provider examples
├── scripts/             # Shared cloud-init / Windows helpers
├── LICENSE.md
└── README.md
```

| Area | What it is | Details |
|------|------------|---------|
| [`vastdata/`](vastdata/) | VAST provider examples (auth, views, block, full config) | [`vastdata/README.md`](vastdata/README.md) |
| [`azure/`](azure/) | Networks, identity, VMs, AKS, AVD | [`azure/README.md`](azure/README.md) |
| [`gcp/`](gcp/) | VPCs/firewalls/DNS, project roll-up, VMs, GKE | [`gcp/README.md`](gcp/README.md) |
| [`aws/`](aws/) | EC2 / IAM patterns | `aws/` |
| [`oci/`](oci/) | OCI templates | [`oci/README.md`](oci/README.md) |
| [`scripts/`](scripts/) | Cloud-init, Windows specialize | [`scripts/README.md`](scripts/README.md) |

## Conventions

- **One stack per folder** — independent root module.
- **Secrets stay local** — untracked `*.tfvars` / env vars; commit `*.tfvars.example` only.
- **Examples use placeholders** — e.g. `192.168.1.100`, `lab.example.com`, `gcp-project-id`.

## Author

**Karl Vietmeier**

## License

Apache 2.0 — see [LICENSE.md](LICENSE.md).
