# IT ticket — after-hours lab auto-shutdown (IAM)

**Copy/paste below into ITDESK / IdC.**

---

## Summary
Allow Solutions to create/modify after-hours EC2 auto-shutdown automation (EventBridge Scheduler → Lambda → StopInstances) so tagged lab/scratch VMs stop evenings/weekends and do not burn idle compute.

## Account / identity
- Account: `110450271409`
- Region: `us-west-2`
- SSO role: `AWSReservedSSO_AWS-Polaris-Solutions_94be6ac475a41b4b` (current Solutions profile)
- Preferred long-term: Solutions-SRE permission set / workload lane (not cluster CI)

## What failed (2026-09-20)
Terraform apply of lab auto-shutdown stack denied:

```
AccessDenied: iam:CreateRole
  on arn:aws:iam::110450271409:role/solutions-lab-autoshutdown-lambda
  (same for solutions-lab-autoshutdown-scheduler)
```

Also blocked for this use case: `ec2:StopInstances` (Lambda needs it to stop tagged instances).

## Ask
Attach (or merge) the attached policy to our Solutions permission set so we can create and update:

| Resource | Purpose |
|----------|---------|
| IAM roles under path `/solutions/` | Lambda execution + Scheduler invoke |
| Lambda function `solutions-lab-autoshutdown` | Stop running instances tagged `AutoShutdown=true` |
| EventBridge Scheduler schedule | Weekdays ~19:00 America/Los_Angeles (configurable) |

**Policy JSON (ready to attach):**  
`Terraform/aws/ec2/autoshutdown/iam-policy-autoshutdown.json`

Scoped IAM: `arn:aws:iam::*:role/solutions/*` only — not unrestricted CreateRole.

## Why
Cost control. Lab clients/scratch boxes left running overnight/weekends. Opt-in via tag `AutoShutdown=true`; leave unset on long-running services / always-on hosts. No VPC/underlay changes requested.

## Not in scope
- No VPC / subnet / route / TGW / IGW changes
- No changes to always-on / long-running service instances (tag opt-in only)
- Not cluster deploy/CI lifecycle

## Acceptance
1. `iam:CreateRole` succeeds for roles under `/solutions/`
2. Can create/update Lambda + Scheduler for auto-shutdown
3. Lambda role can `ec2:DescribeInstances` + `ec2:StopInstances`
4. Manual test: `aws lambda invoke --function-name solutions-lab-autoshutdown …` stops only tagged running instances
