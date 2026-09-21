# oci/

Terraform stacks for Oracle Cloud Infrastructure (OCI) lab / POC work.

## Layout

| Directory | Purpose |
|-----------|---------|
| [`templates/`](templates/) | Starter / reference root module |
| [`vms/`](vms/) | VM examples (e.g. [`vms/multi/`](vms/multi/)) |

## Prerequisites

- Terraform + [OCI provider](https://registry.terraform.io/providers/oracle/oci/latest/docs)
- OCI tenancy credentials / API key config (usually `~/.oci/config`)
- Keep real tfvars and keys out of git

## Typical workflow

```bash
cd templates   # or vms/multi
terraform init
terraform plan
terraform apply
```

## Related

- Shared Linux bootstrap: [`../scripts/cloud-init/`](../scripts/cloud-init/)
- Repo conventions: [`../README.md`](../README.md)
