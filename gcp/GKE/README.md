# gcp/GKE/

GKE lab and AI/demo clusters for this repo.

| Directory | Purpose | Show to IT? |
|-----------|---------|-------------|
| [`gke-aicluster/`](gke-aicluster/) | **Preferred** — VPC-native (Andromeda) cluster, apps staging pool, scale-from-zero GPU/CPU, VPN-reachable pods, cost timers | **Yes — start here:** [`gke-aicluster/README.md`](gke-aicluster/README.md) |
| [`gke-testing/`](gke-testing/) | Older basic cluster experiment (incomplete networking; not the IT reference) | No |
| [`kubernetes/`](kubernetes/) | Sample app manifests / experiments | Optional |

## IT one-pager

The **AI cluster** is built so:

1. **Spend stays low** — GPU and large CPU pools have `min_node_count = 0` (no idle accelerators).  
2. **Devs stage first** — cheap `apps-pool` (`e2`) for Flask / VAST I/O before GPU/TPU.  
3. **VPN reaches pods** — one subnet with alias IP ranges; example VPC plan `10.199.0.0/20` is shared with other apps (GKE only takes modest secondary slices).  
4. **Timers exist** — Jobs with deadlines and autostop CronJobs so demos do not run overnight.

Full explanation and usage: **[`gke-aicluster/README.md`](gke-aicluster/README.md)**.
