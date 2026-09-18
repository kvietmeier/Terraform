# gcp/

Terraform stacks for GCP lab and POC infrastructure: core networking/DNS, a project roll-up module, VMs, GKE, and TPUs.

## Layout

```text
gcp/
├── CoreInfra/          # Discrete production-style pieces (VPC, FW, DNS, NAT, VPN, IAP, VMs)
├── configure-project/  # Roll-up of CoreInfra into one apply (preferred for a full project)
├── VMs/                # Standalone VM patterns
├── GKE/                # GKE clusters + sample apps
├── tpus/               # TPU node / discovery experiments
├── templates/          # Starters
├── testing/            # Scratch (AD domain, misc VMs, …)
└── scripts/            # Stub → use ../../scripts/gcp instead
```

| Directory | Purpose |
|-----------|---------|
| [`CoreInfra/`](CoreInfra/) | VPCs, firewalls, DNS forwarders/zones, NAT, VPN, IAP, core VMs — apply piece by piece |
| [`configure-project/`](configure-project/) | Single root module wiring CoreInfra modules with feature flags |
| [`VMs/`](VMs/) | Multi-VM, proxy, Windows, image, migration examples |
| [`GKE/`](GKE/) | GKE testing / AI cluster + Kubernetes sample apps |
| [`tpus/`](tpus/) | TPU nodes and discovery helpers |
| [`templates/`](templates/), [`testing/`](testing/) | Reference and experimental stacks |

GCP-only helpers (listing, AD metadata, SSH snippets): [`../scripts/gcp/`](../scripts/gcp/).

## Prerequisites

- Terraform installed
- GCP project + credentials (`gcloud auth application-default login` or a service account)
- [Google provider docs](https://registry.terraform.io/providers/hashicorp/google/latest/docs)

## Typical workflow

**Full project (recommended when you want VPC + firewalls + DNS together):**

```bash
cd gcp/configure-project
cp terraform.tfvars.example terraform.tfvars
# edit project_id, feature flags, secrets
terraform init && terraform plan && terraform apply
```

Details and apply graph: [`configure-project/README.md`](configure-project/README.md).

**Individual CoreInfra pieces** (unchanged by the roll-up):

```bash
cd gcp/CoreInfra/vpcs/core
terraform init && terraform plan && terraform apply
```

## GCP quirks (VMs)

Many Linux images on GCP do **not** ship with cloud-init. Stacks often install it via `startup-script` metadata, then attach user-data / SSH keys:

```terraform
metadata = {
  startup-script = <<-EOT
  #!/bin/bash
  command -v cloud-init &>/dev/null || (dnf install -y cloud-init && reboot)
  EOT

  ssh-keys           = "${var.ssh_user}:${local.ssh_key_content}"
  user-data          = "${data.cloudinit_config.system_setup.rendered}"
  serial-port-enable = true
}
```

Multiple SSH keys: put them in a file and reference that file from metadata, variables, and tfvars (GCP defaults to a single key otherwise).

Day-to-day Linux bootstrap content: [`../scripts/cloud-init/`](../scripts/cloud-init/).

## Docs

- [Terraform on GCP](https://cloud.google.com/docs/terraform)
- [HashiCorp Learn — GCP](https://developer.hashicorp.com/terraform/tutorials/gcp-get-started)
- [Google provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)

## Author

**Karl Vietmeier**

## License

Apache 2.0 — see [LICENSE.md](../LICENSE.md).
