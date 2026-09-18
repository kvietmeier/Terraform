# Technical checklist

**IT / Solutions brief (diagrams + who-does-what):** [`README.md`](README.md)

| Pool | SKU | min | Role |
|------|-----|-----|------|
| `system-pool` | `e2-standard-4` | fixed | kube-system |
| `apps-pool` | `e2-standard-2` | 0 | Staging (Solutions default) |
| `de-team-pool1` | `n4-standard-16` | 0 | CPU-heavy |
| `gpu-l4-pool` | `g2` + L4 | 0 | GPU |

| Slice | Example | Role |
|-------|---------|------|
| VPC / VPN | `10.199.0.0/20` | Whole VPC plan |
| Primary | `10.199.0.0/24` | Nodes + other apps |
| `gke-pods` | `10.199.8.0/22` | Pod alias IPs |
| `gke-services` | `10.199.12.0/24` | ClusterIPs |

Solutions: deploy apps only. New SKU → request a pool (`min=0`), not a new cluster.
