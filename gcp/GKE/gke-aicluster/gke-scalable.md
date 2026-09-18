# Technical notes — scale-from-zero + VPC-native

For the **IT-facing overview and usage**, use **[`README.md`](README.md)**.

This file keeps a short technical checklist for implementers.

## Cost / pools (quick)

| Pool | SKU | min | Role |
|------|-----|-----|------|
| `system-pool` | `e2-standard-4` | fixed | kube-system |
| `apps-pool` | `e2-standard-2` | 0 (default) | Staging before GPU/TPU |
| `de-team-pool1` | `n4-standard-16` | 0 | CPU-heavy |
| `gpu-l4-pool` | `g2` + L4 | 0 | GPU |

## Networking carve (example)

| Slice | Example | Role |
|-------|---------|------|
| VPC / VPN | `10.199.0.0/20` | Whole VPC plan |
| Primary | `10.199.0.0/24` | Nodes + other subnet apps |
| `gke-pods` | `10.199.8.0/22` | Pod alias IPs |
| `gke-services` | `10.199.12.0/24` | ClusterIPs |

## Examples

- [`examples/apps-staging-flask.yaml`](examples/apps-staging-flask.yaml)  
- [`examples/job-gpu-l4-timed.yaml`](examples/job-gpu-l4-timed.yaml)  
- [`examples/deployment-autostop-cronjob.yaml`](examples/deployment-autostop-cronjob.yaml)  

```bash
cd gcp/GKE/gke-aicluster
terraform init && terraform plan && terraform apply
```
