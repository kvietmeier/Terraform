# GKE AI / lab cluster (scale-from-zero)

**Audience:** IT, platform, and solutions engineering  
**Code:** [`gke-scalable.main.tf`](gke-scalable.main.tf)  
**Examples:** [`examples/`](examples/)

This stack provisions a **private, VPC-native GKE cluster** designed so developers can stage apps (Flask/web, VAST I/O), then move to CPU-heavy or GPU workloads **without leaving idle accelerators running**.

---

## Why this design (IT summary)

| Goal | How we meet it |
|------|----------------|
| Control cloud spend | GPU / CPU-heavy node pools **scale from 0** — no idle L4/n4 VMs |
| Safe onboarding | Cheap **`apps-pool`** staging area before GPU/TPU |
| Reach apps over VPN | **Andromeda / VPC-native** networking: Pod IPs are real VPC addresses from subnet **alias (secondary) ranges** |
| Talk to VAST | Nodes tagged `vast-client` for existing firewall rules |
| Guardrails for demos | Timed Jobs and autostop CronJobs so forgotten pods do not burn budget overnight |

**Always-on cost is intentional and small:** only `system-pool` (kube-dns / system pods) stays up. Everything else is demand-driven.

```text
  Developer flow
  ──────────────
  1. Stage on apps-pool (cheap e2)     → prove VPN, Flask, VAST I/O
  2. Promote to GPU / CPU-heavy        → same cluster, different nodeSelector
  3. Finish or timer fires             → pods gone → expensive pools → 0 nodes
```

---

## Architecture

### Node pools

| Pool | Machine (default) | Min nodes | Purpose |
|------|-------------------|-----------|---------|
| `system-pool` | `e2-standard-4` | fixed (default **1**) | Kubernetes system pods only |
| `apps-pool` | `e2-standard-2` | **0** (optional `1` for tiny staging floor) | Staging: Flask, smoke tests, VAST client I/O |
| `de-team-pool1` | `n4-standard-16` | **0** | CPU-heavy workloads |
| `gpu-l4-pool` | `g2-standard-8` + NVIDIA L4 | **0** | GPU workloads |

Terraform **declares** the GPU/CPU pools so they are ready to schedule into. The autoscaler **does not create VMs** until a matching pod is pending. When pods finish or replicas go to `0`, those nodes scale back to **zero**.

```text
  system-pool     ── always on (small e2)
  apps-pool       ── cheap staging (prefer min=0)
  cpu-heavy / GPU ── min=0 forever; cold-start is the cost of no idle burn
```

### Networking (required pattern)

GKE uses **one subnet** with **alias IP ranges** (VPC-native / Andromeda). This is the supported, scalable model. Pod IPs appear on the VPC and can be reached over VPN if that address plan is advertised.

**Example address plan** — `10.199.0.0/20` is the **whole VPC** (other apps included). Do **not** assign the entire `/20` to GKE.

| Slice | Example CIDR | Size | Role |
|-------|--------------|------|------|
| VPC plan (advertise on VPN) | `10.199.0.0/20` | 4096 | Entire lab VPC routable space |
| Subnet primary | `10.199.0.0/24` | 256 | Node IPs + other VMs on this subnet |
| Alias `gke-pods` | `10.199.8.0/22` | 1024 | Pod IPs (apps reachable via VPN) |
| Alias `gke-services` | `10.199.12.0/24` | 256 | Service ClusterIPs |
| Remainder of `/20` | — | rest | Other subnets, apps, growth |

```text
                         VPN advertises 10.199.0.0/20
                                         │
      IT / laptop / on-prem              │
      curl http://10.199.8.37:8080       │  (Flask/web running IN a pod)
               │                         ▼
               │                   VPC (e.g. summit-vpc)
               │         ┌──────────────────────────────────────┐
               │         │  ONE subnet (e.g. subnet19-…)        │
               │         │                                      │
               │         │  primary 10.199.0.0/24               │
               │         │    • GKE nodes                       │
               │         │    • other lab VMs / apps            │
               │         │                                      │
               └────────►│  alias gke-pods 10.199.8.0/22        │
                         │    • Pod 10.199.8.37  ← Andromeda    │
                         │                                      │
                         │  alias gke-services 10.199.12.0/24   │
                         │                                      │
                         │  (rest of /20 → other resources)     │
                         └──────────────────────────────────────┘

  Correct: VPC-native alias IPs on one subnet → VPN can reach pods.
  Avoid:   routes-based GKE, or burning the whole /20 as “pod CIDR”.
```

Named secondaries must exist on the subnet **before** `terraform apply` (this module references them; it does not invent unmanaged ranges). Private nodes also need **Cloud NAT** and **Private Google Access** on that subnet.

---

## Usage

### Prerequisites (platform / IT)

1. GCP project with Kubernetes Engine API enabled  
2. VPC + subnet with secondaries `gke-pods` / `gke-services` carved as above  
3. Cloud NAT + Private Google Access for private nodes  
4. Confirm GPU SKU availability in the target zone (`g2` + L4)  
5. Terraform ≥ 1.5, authenticated `gcloud` / application-default credentials  

### Deploy the cluster

```bash
cd gcp/GKE/gke-aicluster

# Review / set project, VPC, subnet, optional flags in variables
terraform init
terraform plan
terraform apply
```

Useful variables:

| Variable | Default | Meaning |
|----------|---------|---------|
| `project_id` | (set for your project) | GCP project |
| `vpc_name` / `subnet_name` | summit-vpc / subnet19-… | Network attachment |
| `system_node_count` | `1` | Only always-on system nodes |
| `apps_min_nodes` | `0` | Keep `0`; use `1` only for a tiny always-on staging floor |
| `enable_apps_pool` | `true` | Staging pool |
| `enable_gpu_l4_pool` | `true` | L4 pool (still min=0) |
| `enable_cpu_heavy_pool` | `true` | n4 pool (still min=0) |

Connect:

```bash
# terraform output -raw gcloud_auth_command
gcloud container clusters get-credentials <cluster> --zone <zone> --project <project>
```

### Developer workflow (show this to app teams)

**Step 1 — Stage on cheap apps nodes**

```bash
kubectl apply -f examples/apps-staging-flask.yaml
# Verify VPN reachability to the pod IP / Service, VAST mounts, basic I/O
kubectl scale deploy/apps-staging-flask --replicas=0   # apps-pool → toward 0
```

**Step 2 — GPU (or CPU-heavy) only after staging works**

```bash
kubectl apply -f examples/job-gpu-l4-timed.yaml
# Job has activeDeadlineSeconds → killed on timer → GPU nodes scale to 0
```

**Step 3 — Long-running demos must autostop**

```bash
kubectl apply -f examples/deployment-autostop-cronjob.yaml
# Nightly CronJob (and optional 2h timer Job) scales Deployment to 0
```

| Example | What it demonstrates |
|---------|----------------------|
| [`examples/apps-staging-flask.yaml`](examples/apps-staging-flask.yaml) | Staging on `pool=apps` |
| [`examples/job-gpu-l4-timed.yaml`](examples/job-gpu-l4-timed.yaml) | GPU Job with hard time limit |
| [`examples/deployment-autostop-cronjob.yaml`](examples/deployment-autostop-cronjob.yaml) | Schedule / timer → replicas 0 |

### How workloads select pools

| Workload | `nodeSelector` / tolerations | Notes |
|----------|------------------------------|--------|
| Staging | `pool: apps` | No GPU taint; `vast-client` on nodes |
| CPU heavy | tolerate `workload=heavy` | After apps staging |
| GPU L4 | `accelerator: l4`, tolerate `nvidia.com/gpu=present`, request `nvidia.com/gpu: 1` | After apps staging |

---

## Cost & operations expectations

- **Cold start:** First GPU/CPU-heavy pod after idle waits for node provision (+ GPU drivers). Expected tradeoff for zero idle spend.  
- **Forgotten Deployments** with `replicas ≥ 1` keep nodes up — require timers, CronJobs, or scale-to-zero as part of the runbook.  
- **system-pool** is the only required always-on compute; size with `system_node_count` (use `2` only if you need system-pod HA).  
- **apps_min_nodes=1** is optional and cheap; prefer `0` for strict no-idle policy.

---

## Related docs

- Technical notes / diagrams: [`gke-scalable.md`](gke-scalable.md)  
- Parent GCP map: [`../../README.md`](../../README.md)  
- VPC secondary ranges: [`../../CoreInfra/vpcs/core/`](../../CoreInfra/vpcs/core/)  

## Author

**Karl Vietmeier**
