# GKE AI / lab cluster (scale-from-zero)

**Audience:** IT, platform, and Solutions engineering  
**Code:** [`gke-scalable.main.tf`](gke-scalable.main.tf)  
**Examples:** [`examples/`](examples/)

Shared **private, VPC-native GKE** for lab/demo work. Platform owns the cluster(s); **Solutions (and other app teams) only deploy apps** — they do not create clusters.

---

## Who does what

| Role | Does | Does not |
|------|------|----------|
| **Platform / IT** | Build & maintain regional clusters (Terraform), VPC/alias CIDRs, NAT, firewalls, node pools; **apply / destroy** when capacity is needed or not | Day-to-day app deploys |
| **Solutions / app teams** | `kubectl apply` manifests; stage on `apps-pool`; promote to GPU/CPU/TPU; use timers / scale to 0 | Create GKE clusters, invent pod CIDRs, or manage node pools day-to-day |
| **Request to platform** | “Please add a node pool for SKU *X*” or “bring up / tear down the *region* cluster” | — |

**Correct mental model:** pools are declared in Terraform and scale from zero while a cluster exists. Worst case for a new accelerator is a **pool request**. For quiet periods, platform can **shut the whole cluster down** (see below) — Solutions still never builds GKE themselves.

```text
  Solutions team                         Platform
  ──────────────                         ────────
  kubectl apply -f my-app.yaml    ◄────  terraform apply   (bring cluster up)
  pick pool via nodeSelector             terraform destroy (full shutdown)
  timer / scale → 0 when done            add pool if new GPU/TPU SKU needed
```

---

## Multi-region: one cluster where the accelerators are

Do **not** run one mega-cluster and hope GPUs/TPUs appear everywhere. Accelerator inventory is **regional (often zonal)**. The intended footprint is **one GKE cluster per accelerator region** — colocated with the TPU/GPU capacity you actually use.

Typical pattern (example — pick the four regions that match your quotas and VAST/VPN footprint):

| Region (example) | Why a dedicated cluster |
|------------------|-------------------------|
| `us-central1` | Common GPU / TPU availability |
| `us-east5` | TPU-heavy capacity in many orgs |
| `europe-west4` | EU accelerator + data locality |
| `asia-northeast1` | APAC accelerator + data locality |

```text
  VPC (shared hub) + VPN
       │
       ├── GKE us-central1     ← colocated with GPU/TPU stock there
       ├── GKE us-east5        ← colocated with TPU/GPU stock there
       ├── GKE europe-west4
       └── GKE asia-northeast1

  Same Terraform pattern per region (this folder as the template).
  Solutions: get-credentials for the region they need → deploy apps only.
```

**Why colocate**

- GPUs/TPUs cannot be scheduled from a cluster in another region.  
- Cold-start and quota checks stay local to where capacity exists.  
- You can leave three regions **destroyed** and only `apply` the region you need for a demo or engagement.  
- Each cluster still uses **scale-from-zero** node pools — and can be torn down entirely when idle for longer stretches.

This folder is the **template** for one regional cluster (today’s defaults point at a single zone). Replicate with per-region state/vars (or workspaces) — same code, different `location` / subnet / alias CIDRs.

---

## Full shutdown vs scale-to-zero

Two cost levers; use both.

| Lever | What happens | When to use |
|-------|----------------|-------------|
| **Scale-to-zero (pools)** | GPU/CPU/apps nodes → 0; **control plane + system-pool still bill** | Between Jobs the same day / week |
| **Shut down the cluster** | Delete the GKE cluster (and its nodes) | Weekend, between projects, region not in use |

### Terraform apply / destroy (recommended)

Because the cluster is code in this repo, platform can treat it as **ephemeral infrastructure**:

```bash
cd gcp/GKE/gke-aicluster
terraform init
terraform apply     # create or update the regional cluster when needed
# … Solutions deploys apps …
terraform destroy   # full teardown when the region is idle — no control-plane charge
```

- **`apply`** when an engagement needs that region’s GPUs/TPUs.  
- **`destroy`** when finished (or destroy only the unused regional states).  
- Recreate is expected to be **repeatable** (same VPC/alias plan, same pool definitions).  
- Ensure `deletion_protection = false` on the cluster (already set in this template) so destroy is not blocked.  
- App manifests live in git (`examples/` or team repos) — they are re-applied after the next `apply` + `get-credentials`.

### Without destroying (cluster left up)

- Scale Deployments/Jobs to 0 / use timer examples → expensive pools → 0.  
- You still pay for the **GKE control plane** (and the small `system-pool`). For long idle periods, prefer **`terraform destroy`**.

---

## Why this design

| Goal | How we meet it |
|------|----------------|
| Solutions doesn’t manage GKE | Shared regional clusters; teams only deploy pods |
| Accelerators where they live | One cluster per GPU/TPU region (up to ~4) |
| Control cloud spend | Pools **scale from 0**; idle regions **destroy** entirely |
| Safe onboarding | Cheap **`apps-pool`** staging before GPU/TPU |
| Reach apps over VPN | **VPC-native / Andromeda**: Pod IPs are VPC **alias** addresses |
| Talk to VAST | Nodes tagged `vast-client` for existing firewall rules |
| Demo guardrails | Timed Jobs + autostop CronJobs |

```text
  Developer flow (Solutions)
  1. Stage on apps-pool (cheap e2)     → prove VPN, Flask, VAST I/O
  2. Promote to GPU / CPU / TPU        → same regional cluster, different nodeSelector
  3. Finish or timer fires             → pods gone → expensive pools → 0
  4. (Platform) long idle              → terraform destroy that regional cluster
```

---

## Architecture (single regional cluster)

### Node pools

| Pool | Machine (default) | Min nodes | Purpose |
|------|-------------------|-----------|---------|
| `system-pool` | `e2-standard-4` | fixed (default **1**) | kube-system only (while cluster exists) |
| `apps-pool` | `e2-standard-2` | **0** (optional `1`) | Staging: Flask, smoke tests, VAST I/O |
| `de-team-pool1` | `n4-standard-16` | **0** | CPU-heavy |
| `gpu-l4-pool` | `g2-standard-8` + NVIDIA L4 | **0** | GPU |

Need H100 / TPU / another GPU in **this** region? **Request a new pool** (`min_node_count = 0`). Need that SKU in **another** region? Use (or `apply`) the cluster colocated there.

### Networking (required pattern)

**One subnet per regional cluster** with **alias IP ranges** (VPC-native). Pod IPs are real VPC addresses — reachable over VPN if that plan is advertised.

**Example carve** — `10.199.0.0/20` as a **VPC plan** (other apps included). Do **not** give GKE the entire `/20`. Each region needs its own non-overlapping primary + `gke-pods` / `gke-services` secondaries on that region’s subnet.

| Slice | Example CIDR | Role |
|-------|--------------|------|
| VPC plan (VPN) | `10.199.0.0/20` (example) | Shared routable space — plan per region carefully |
| Subnet primary | e.g. `10.199.0.0/24` | Node IPs + other VMs on that subnet |
| Alias `gke-pods` | e.g. `10.199.8.0/22` | Pod IPs (VPN-reachable apps) |
| Alias `gke-services` | e.g. `10.199.12.0/24` | Service ClusterIPs |
| Leftover | rest of plan | Other subnets / apps / growth |

Named secondaries must exist **before** `terraform apply`. Private nodes need **Cloud NAT** + **Private Google Access** on that subnet.

---

## Usage

### Platform — bring a region up or tear it down

```bash
cd gcp/GKE/gke-aicluster
terraform init
terraform apply      # create / update
terraform destroy    # full shutdown when the region is not needed
```

| Variable | Default | Meaning |
|----------|---------|---------|
| `project_id` | set for env | GCP project |
| `location` | `us-central1-a` | Zone/region for **this** cluster (colocate with GPU/TPU) |
| `vpc_name` / `subnet_name` | summit-vpc / subnet19-… | Regional subnet with alias ranges |
| `system_node_count` | `1` | Only always-on nodes while cluster exists |
| `apps_min_nodes` | `0` | Prefer `0` |
| `enable_*_pool` | `true` | Pool definitions (GPU/CPU still min=0) |

```bash
gcloud container clusters get-credentials <cluster> --zone <zone> --project <project>
```

### Solutions — deploy apps only

**1. Stage on cheap apps nodes**

```bash
kubectl apply -f examples/apps-staging-flask.yaml
kubectl scale deploy/apps-staging-flask --replicas=0
```

**2. GPU / CPU-heavy after staging works**

```bash
kubectl apply -f examples/job-gpu-l4-timed.yaml
```

**3. Long-running demos must autostop**

```bash
kubectl apply -f examples/deployment-autostop-cronjob.yaml
```

| Example | Purpose |
|---------|---------|
| [`examples/apps-staging-flask.yaml`](examples/apps-staging-flask.yaml) | Staging on `pool=apps` |
| [`examples/job-gpu-l4-timed.yaml`](examples/job-gpu-l4-timed.yaml) | GPU Job with hard time limit |
| [`examples/deployment-autostop-cronjob.yaml`](examples/deployment-autostop-cronjob.yaml) | Nightly / timer → replicas 0 |

### Pool selection (Solutions)

| Workload | `nodeSelector` / tolerations |
|----------|------------------------------|
| Staging | `pool: apps` |
| CPU heavy | tolerate `workload=heavy` |
| GPU L4 | `accelerator: l4` + tolerate `nvidia.com/gpu=present` + `nvidia.com/gpu: 1` |

---

## Cost expectations

- **Pools at min=0** stop node burn between Jobs; **control plane** still costs if the cluster is left up.  
- **Long idle / unused region:** `terraform destroy` — no cluster, no control plane.  
- **Cold start** after scale-from-zero (or after recreate) is expected.  
- New SKU = **pool request** in the right regional cluster; new geography = **another regional apply**, not one global cluster.

---

## Related

- Short checklist: [`gke-scalable.md`](gke-scalable.md)  
- GKE index: [`../README.md`](../README.md)  
- GCP map: [`../../README.md`](../../README.md)  
- VPC secondaries: [`../../CoreInfra/vpcs/core/`](../../CoreInfra/vpcs/core/)  

## Author

**Karl Vietmeier**
