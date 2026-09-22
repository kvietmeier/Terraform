# IT ticket — Solutions AWS access (band-aid NOW)

**Copy/paste into ITDESK / IdC. One ticket — not drip-feed.**

---

## Summary
Solutions needs a usable AWS envelope for lab clients, demos, cost control, and day-2 ops. Today the SSO role we inherit (`AWS-Polaris-Solutions` on account `110450271409`) can launch/terminate some things but blocks the basic actions that save money and let us operate. We are filing **one** ticket with everything confirmed denied — please fix as an interim band-aid on this permission set **or** stand up the agreed Solutions-SRE lane; do not trickle Allows over weeks.

## Framing (important)
- **Polaris / VastCloud = VAST clusters only.** Lab clients, DBs, scratch boxes, auto-shutdown, golden AMIs, demo LBs are **outside** that.
- Role name says “Polaris-Solutions” but this is the accreted profile we use for Solutions work — not the long-term design.
- **Preferred:** Solutions-SRE account + permission set + IdC group (overlay existing VPC; no underlay takeover).
- **Acceptable interim:** widen **this** permission set (+ SCP exceptions where IAM already allows but Org denies) so we are not blocked Fri/Sat when IT is dark.
- **Safety we want:** IT baseline SG = attach/detach only; deny unapproved `0.0.0.0/0` / `::/0`; path stays Cato → TGW. We are **not** asking for VPC/subnet/route/IGW/NAT/TGW create.

## Account / identity
- Account: `110450271409`
- Region (primary evidence): `us-west-2`
- SSO role: `AWSReservedSSO_AWS-Polaris-Solutions_94be6ac475a41b4b`
- Policy JSON for cost timer: `Terraform/aws/ec2/autoshutdown/iam-policy-autoshutdown.json`
- Full exhibit log: `personal/notes/AWS Permissions.txt`

## Confirmed failures (please fix these)

### A) Cost control — cannot even stop a VM
```
2026-09-21 — console StopInstances denied
  instance i-04cb3ca1a93312b65
  ec2:StopInstances → AccessDenied
```
We **have** `TerminateInstances` (destructive) but **not** Stop/Start (safe, keeps disk). That is backwards for cost.

**Need:** `ec2:StopInstances`, `ec2:StartInstances`

### B) After-hours auto-shutdown automation
```
2026-09-20 — terraform apply aws/ec2/autoshutdown/
  iam:CreateRole denied for:
    solutions-lab-autoshutdown-lambda
    solutions-lab-autoshutdown-scheduler
```
Tag-driven weekday stop (`AutoShutdown=true`) cannot be deployed. Overnight lab burn continues.

**Need:** attach `iam-policy-autoshutdown.json` (IAM under `role/solutions/*` + Lambda + Scheduler + StopInstances)

### C) Change security group on a running instance
```
Failed to change security groups for ENI …
  ec2:ModifyNetworkInterfaceAttribute → AccessDenied
```
Forces destroy/recreate of clients to attach IT baseline / Solutions SGs.

**Need:** `ec2:ModifyNetworkInterfaceAttribute` (attach/detach SGs on ENI)

### D) Create / modify Solutions-owned security groups (testing / error injection)
IAM may list some SG actions; **Org SCP** still denies CreateSecurityGroup / Authorize / Revoke.
We need to **create and modify our own SGs** for lab testing and controlled error injection
(e.g. tighten/deny paths, break connectivity on purpose, then restore) without waiting on IT
for every rule change. Forces workarounds or tickets for routine demo/test hygiene today.

**Need:** SCP exception + IAM for Solutions-owned SG create/edit:
- `ec2:CreateSecurityGroup` / `DeleteSecurityGroup`
- `AuthorizeSecurityGroupIngress` / `Egress`
- `RevokeSecurityGroupIngress` / `Egress`
- `ModifySecurityGroupRules`
- `UpdateSecurityGroupRuleDescriptionsIngress` / `Egress`

**Guardrails we accept:** IT baseline (“default”) SG = **attach/detach only** (we do not edit its rules).
No unapproved public `0.0.0.0/0` / `::/0`. No VPC/subnet/route/TGW changes.

### E) Golden AMI
```
2026-09-20 — ec2:CreateImage denied on i-0da3bb34640406a69
```
Cannot bake lab image after cloud-init; every launch re-pays bootstrap time/$.

**Need:** `ec2:CreateImage`, `DeregisterImage`, `CopyImage`, `ModifyImageAttribute`

### F) Serial console break-glass
Account has Serial Console enabled; role cannot open session (`SendSerialConsoleSSHPublicKey` denied). Blocks recovery when SSH/cloud-init fails.

**Need:** `ec2-instance-connect:SendSerialConsoleSSHPublicKey` (+ ideally `SendSSHPublicKey`); optional SSM StartSession

### G) Demo ingress / AI (also blocked)
ImplicitDeny / AccessDenied for: ELB create (LoadBalancer/TargetGroup), Route53 Resolver rule create/associate, Bedrock/SageMaker invoke.

**Need:** ELB write (corp path), `route53resolver:CreateResolverRule` + Associate*, `bedrock:InvokeModel*`, `sagemaker:InvokeEndpoint*`

### H) Observability / troubleshooting (easy to miss)
Day-2 needs **read** access to prove failures, debug demos, and verify auto-shutdown. Prefer attaching **ReadOnlyAccess** (or ViewOnly) plus these if not already covered:

| Area | Why | Actions (minimum) |
|------|-----|-------------------|
| **CloudWatch Logs** | View Lambda (autoshutdown), ALB, app /vpc flow if present | `logs:Describe*`, `logs:Get*`, `logs:FilterLogEvents`, `logs:StartQuery` / `GetQueryResults` |
| **CloudWatch Metrics** | CPU/network, “is it idle?”, alarm hygiene | `cloudwatch:GetMetricData`, `GetMetricStatistics`, `ListMetrics`, `DescribeAlarms` |
| **CloudTrail** | Document AccessDenied / who changed what | `cloudtrail:LookupEvents`, `DescribeTrails`, `GetTrailStatus`, `ListEventDataStores` |
| **EC2 console output** | Boot/cloud-init without serial | `ec2:GetConsoleOutput`, `GetConsoleScreenshot` |
| **SG rule read** | Console SG UI often needs this explicitly | `ec2:DescribeSecurityGroupRules` |
| **VPC read hygiene** | Console VPC pages blank otherwise (seen on VOC-Admin) | `DescribeVpcAttribute`, `DescribeRouteTables`, `DescribeNetworkAcls`, `DescribeDhcpOptions` |
| **SSM (optional)** | Break-glass without SSH | `ssm:StartSession`, `DescribeSessions`, `GetConnectionStatus` |
| **Cost (optional but fits $$$ story)** | Show overnight burn before/after Stop | `ce:GetCostAndUsage`, `ce:GetCostForecast` (or Billing console read) |

**Note:** Polaris-Solutions may already carry ReadOnlyAccess for some of this — please **confirm** Logs/Metrics/CloudTrail work in console; if not, grant explicitly. VOC-Admin historically lacked several Describe* and CloudTrail lookups.

### I) Terraform remote state — cannot create / write S3 state bucket
```
2026-09-21 — IAM SimulatePrincipalPolicy on AWS-Polaris-Solutions (account 110450271409)
  target: arn:aws:s3:::karlv-tfstate-110450271409
  s3:CreateBucket                 → implicitDeny
  s3:PutBucketVersioning          → implicitDeny
  s3:PutEncryptionConfiguration   → implicitDeny
  s3:PutBucketPublicAccessBlock   → implicitDeny
  s3:PutObject                    → implicitDeny
  s3:GetObject / ListBucket       → allowed (ReadOnlyAccess only)
```
Org SCP is fine (`AllowedByOrganizations: True`) — the permission set simply has **no S3 write**.
Without a writable state bucket, every lab stack is local `terraform.tfstate` on a laptop (lost, unshared, no locking).

**Need (prefix-scoped is fine):** in the Solutions / SRE **QA (or lab) account**, allow create + day-2 ops on a dedicated TF state bucket, e.g. prefix `solutions-tfstate-` / `*-tfstate-*`:
- `s3:CreateBucket`, `DeleteBucket`, `ListBucket`, `GetBucketLocation`
- `s3:PutBucketVersioning`, `GetBucketVersioning`
- `s3:PutEncryptionConfiguration`, `GetEncryptionConfiguration`
- `s3:PutBucketPublicAccessBlock`, `GetBucketPublicAccessBlock`
- `s3:GetObject`, `PutObject`, `DeleteObject` (state read/write)
- DynamoDB lock table: create/`PutItem`/`GetItem`/`DeleteItem`/`DescribeTable` on `solutions-tfstate-lock*`

**Hand IT:** [`../../solutions-sre/iam-policy-tfstate.json`](../../solutions-sre/iam-policy-tfstate.json)  
**Standalone ask:** [`../../solutions-sre/IT-ASK-TFSTATE.md`](../../solutions-sre/IT-ASK-TFSTATE.md)

**Guardrails we accept:** no org-wide S3 admin; one (or few) named prefixes only; public access stays blocked; not asking to hijack CI artifact buckets.

## Not asking for
- CreateVpc / Subnet / Route / IGW / NAT / TGW / VPN
- Unapproved public `0.0.0.0/0` or `::/0` ingress
- Editing IT baseline SG **rules** (attach/detach only)
- Turning DevQA **CI** accounts into full SRE sandboxes (we do need TF state + lab clients in a **Solutions QA / lab** account)

## Acceptance (band-aid done when)
1. Console can **Stop** and **Start** a lab instance we launched  
2. Autoshutdown stack applies (`CreateRole` under `/solutions/` + schedule + Lambda stops tagged instances)  
3. Can change SG on a running ENI without recreate  
4. Can **create and modify** a Solutions-owned SG for testing / error injection (tighten, deny, restore) without an IT ticket per change; IT baseline SG rules untouched  
5. `CreateImage` succeeds on a finished lab client  
6. Serial console session opens for break-glass  
7. (If in scope this ticket) ELB + Resolver rule + Bedrock/SageMaker invoke work for a simple demo  
8. Can view CloudWatch Logs (FilterLogEvents) for our Lambda/ALB; CloudTrail LookupEvents; EC2 console output; SG rules in console  
9. Can `CreateBucket` + enable versioning/encryption/public-block on a prefix-scoped TF state bucket, then `PutObject`/`GetObject`/`DeleteObject` state keys, plus DynamoDB lock table day-2 (`GetItem`/`PutItem`/`DeleteItem`)

## Priority
**Band-aid or now.** Cost controls and day-2 ops are blocked today; drip-feeding individual Allows does not work when IT is offline weekends.
