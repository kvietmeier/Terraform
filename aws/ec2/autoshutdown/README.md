# After-hours auto-shutdown

Stops **running** EC2 instances tagged `AutoShutdown=true` on a weekday schedule.
Use for lab clients, scratch boxes, and other stoppable helpers. Leave the tag
**unset** (or `false`) on long-running services and always-on hosts.

## Policy

| Tag | Effect |
|-----|--------|
| `AutoShutdown=true` | Opt **in** — stopped by the scheduled job |
| missing / `false` | Opt **out** — left alone |

Default schedule: **19:00 Mon–Fri** `America/Los_Angeles` (override in `autoshutdown.auto.tfvars`).

## Required permissions

Hand this JSON to IAM / IdC (or merge into the Solutions permission set):

**[`iam-policy-autoshutdown.json`](./iam-policy-autoshutdown.json)**

Summary:

| Action | Why |
|--------|-----|
| `iam:CreateRole` / `DeleteRole` / `GetRole` / `TagRole` / `PutRolePolicy` / `PassRole` | Roles under `/solutions/` (Lambda + Scheduler) |
| `lambda:CreateFunction` / `Update*` / `DeleteFunction` / `InvokeFunction` / … | Deploy and test the stop function |
| `scheduler:CreateSchedule` / `UpdateSchedule` / `DeleteSchedule` / … | Weekday evening trigger |
| `logs:CreateLogGroup` / `PutRetentionPolicy` / … | Lambda log group |
| `ec2:DescribeInstances` | Find tagged running instances |
| `ec2:StopInstances` | Stop them (the cost control) |
| `ec2:CreateTags` | Optional tagging from the function |

IAM role resources are scoped to `arn:aws:iam::*:role/solutions/*` (matches `path = "/solutions/"` in this stack).

**Exhibit (2026-09-20):** Polaris-Solutions denied `iam:CreateRole` (and `ec2:StopInstances`)
when applying this stack — see `~/github/personal/notes/AWS Permissions.txt`.
Full Solutions template: `../../solutions-sre/solutions-sre.policies.tf`.

## Apply

```bash
cd ~/github/Terraform/aws/ec2/autoshutdown
tfinit && tfapply
```

## Opting instances in

Add `AutoShutdown = "true"` to instance tags (see `../linux_clients/` for an example).
Hosts that must stay up overnight: omit the tag or set `AutoShutdown = "false"`.

## Manual test

```bash
aws lambda invoke --function-name solutions-lab-autoshutdown /tmp/out.json && cat /tmp/out.json
```
