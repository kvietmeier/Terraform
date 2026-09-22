# solutions-sre/

**Prototype / example only — untested. Use at your own risk.**

Terraform starter for an IAM Identity Center permission set aimed at a Solutions / SA / SRE lane: workloads inside platform-provided VPCs, without owning underlay networking (VPC/subnet/route/IGW/NAT/TGW).

This is **not** production-ready. It has not been fully validated. Treat it as a reference pattern to copy and harden for your org — not something to apply blindly.

## What it creates

| Resource | Purpose |
|----------|---------|
| SSO permission set | Named lane (default `Solutions-SRE`) |
| Inline IAM policy | Workload-oriented actions (EC2, limited IAM path, optional S3 prefixes, etc.) |
| Optional `ReadOnlyAccess` | AWS managed policy attachment for Describe/List hygiene |
| Account assignments | Map Identity Center groups/users → AWS accounts (from tfvars) |

All org-specific names, account IDs, and principal IDs come from tfvars — nothing account-specific is hard-coded.

## Prerequisites

- Terraform `>= 1.5` and AWS provider `~> 5.0`
- Apply from the **Identity Center / delegated-admin** account (not a workload account)
- Credentials with rights to manage Identity Center permission sets and assignments
- Copy `solutions-sre.auto.tfvars.example` → `solutions-sre.auto.tfvars` and fill in real values (do not commit secrets or live IDs)

## Typical workflow

```bash
cd solutions-sre
cp solutions-sre.auto.tfvars.example solutions-sre.auto.tfvars
# edit tfvars: region, permission set name, account_assignments, prefixes

terraform init
terraform plan
# review carefully — then apply only if you accept the risk
terraform apply
```

Prefer assigning an Identity Center **group** over per-user assignments. After apply, add users to that group (or the IdP group synced into IdC).

## Scope notes

- **In lane:** EC2 workloads/SGs/ENIs, limited IAM under a path prefix, optional S3 by bucket-name prefix (demo + `solutions-tfstate-*` remote state), DynamoDB lock tables (`solutions-tfstate-lock*`), plus common read/ops actions in the inline policy.
- **Out of lane:** Underlay networking stays with platform/IT + org SCPs. Tune `solutions-sre.policies.tf` to match your envelope before any real use.
- Defaults and tags mark this as an untested template (`Status = untested-template`).

## Terraform remote state (IT ask)

Polaris-Solutions today cannot create/write a state bucket. Copy-paste ask + attachable JSON:

| Artifact | Use |
|----------|-----|
| [`IT-ASK-TFSTATE.md`](IT-ASK-TFSTATE.md) | Standalone ITDESK / IdC ask |
| [`iam-policy-tfstate.json`](iam-policy-tfstate.json) | Minimal prefix-scoped S3 + DynamoDB lock policy |

## Files

| File | Role |
|------|------|
| `solutions-sre.provider.tf` | Terraform + AWS provider |
| `solutions-sre.main.tf` | Permission set, policy attach, assignments |
| `solutions-sre.policies.tf` | Inline IAM policy document |
| `solutions-sre.variables.tf` | Inputs |
| `solutions-sre.outputs.tf` | ARNs, assignment keys, add-user hint |
| `solutions-sre.auto.tfvars.example` | Sample tfvars |
| `iam-policy-tfstate.json` | Band-aid / merge policy for remote state |
| `IT-ASK-TFSTATE.md` | Copy-paste IT ask for S3 + DynamoDB lock |

## Disclaimer

Example / prototype for creating an SRE-style Identity Center role. **Untested.** Example only. **Use at your own risk.** Validate in a non-prod Identity Center admin account before any production apply.

## Related

- Parent AWS layout: [`../README.md`](../README.md)
- Repo conventions: [`../../README.md`](../../README.md)
