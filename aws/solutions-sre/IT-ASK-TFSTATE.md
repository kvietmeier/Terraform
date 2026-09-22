# IT ask — Terraform remote state (S3 + DynamoDB lock)

**Copy/paste. Prefix-scoped only. Solutions QA / lab account — not org-wide S3 admin.**

Hand IT the JSON: [`iam-policy-tfstate.json`](./iam-policy-tfstate.json)

Also folded into the band-aid ticket: [`../ec2/autoshutdown/IT-TICKET.md`](../ec2/autoshutdown/IT-TICKET.md) §I.

---

## Summary

Solutions cannot keep shared Terraform state today. Current SSO (`AWS-Polaris-Solutions` on `110450271409`) can **read** S3 (via ReadOnlyAccess) but **cannot create a state bucket or write state objects** (`s3:CreateBucket` / `PutObject` → `implicitDeny`). Org SCP is fine; the permission set has no S3 write.

Without a writable remote backend, every stack is local `terraform.tfstate` on a laptop (lost, unshared, no locking).

## Ask (either path works)

### Preferred — Solutions-SRE lane
Attach [`iam-policy-tfstate.json`](./iam-policy-tfstate.json) (or merge into the Solutions-SRE permission set / `solutions-sre.policies.tf`) on the **Solutions QA / lab** account so the lane can:
1. Create + harden a bucket under `solutions-tfstate-*`
2. Read/write/delete state objects under that prefix
3. Create + use a DynamoDB lock table `solutions-tfstate-lock*`

### Acceptable interim — IT creates once, then grant day-2
1. **IT creates** (once, in the QA/lab account):
   - Bucket e.g. `solutions-tfstate-<account>` with versioning, SSE-S3 (or KMS), and public access block **all on**
   - DynamoDB table e.g. `solutions-tfstate-lock` — partition key `LockID` (String), on-demand billing
2. **Attach day-2 perms** to Polaris-Solutions (or Solutions-SRE) on that bucket/table only:
   - S3: `ListBucket`, `GetObject`, `PutObject`, `DeleteObject` (+ `GetBucket*` reads if console/CLI hygiene needs them)
   - DynamoDB: `DescribeTable`, `GetItem`, `PutItem`, `DeleteItem`

## Evidence (2026-09-21)

```
IAM SimulatePrincipalPolicy — AWS-Polaris-Solutions / 110450271409
  arn:aws:s3:::karlv-tfstate-110450271409
  s3:CreateBucket / PutBucketVersioning / PutEncryptionConfiguration /
    PutBucketPublicAccessBlock / PutObject  → implicitDeny
  s3:GetObject / ListBucket                 → allowed (ReadOnlyAccess)
  AllowedByOrganizations                    → True  (SCP not the blocker)
```

## Guardrails we accept

- Prefix only: `solutions-tfstate-*` (bucket) + `solutions-tfstate-lock*` (table)
- Public access stays blocked; no org-wide S3/DynamoDB admin
- Not asking for CI artifact buckets or underlay networking

## Acceptance

- `terraform init` with an S3 backend against the bucket succeeds
- Plan/apply can `PutObject` / `GetObject` state keys
- Concurrent applies take a DynamoDB lock (no “state locked forever” from missing table perms)

## Example backend (after bucket exists)

```hcl
terraform {
  backend "s3" {
    bucket         = "solutions-tfstate-<account>"
    key            = "aws/ec2/<stack>/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "solutions-tfstate-lock"
    encrypt        = true
  }
}
```
