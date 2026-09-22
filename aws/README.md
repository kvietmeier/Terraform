# aws/

Terraform stacks and helpers for AWS lab / POC work.

## Layout

| Directory | Purpose |
|-----------|---------|
| [`ec2/`](ec2/) | EC2 examples — Linux/Windows clients, BIND forwarder, auto-shutdown |
| [`solutions-sre/`](solutions-sre/) | Org-agnostic Solutions-style starter (tfvars-driven; not fully tested) |
| [`basic_auth/`](basic_auth/) | Minimal auth / provider smoke pattern |

Non-Terraform AWS helpers (e.g. `launch-lab-client.sh`): [`../scripts/aws/`](../scripts/aws/).

## Prerequisites

- Terraform + [AWS provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- AWS credentials (`AWS_PROFILE` / env keys) with rights for the stack you apply
- Copy any `*.tfvars.example` → local `*.tfvars` (do not commit real values)

## Typical workflow

```bash
cd ec2/<stack>
cp *.tfvars.example something.auto.tfvars   # if present
terraform init
terraform plan
terraform apply
```

## Related

- Shared Linux bootstrap: [`../scripts/cloud-init/`](../scripts/cloud-init/)
- Repo conventions: [`../README.md`](../README.md)
