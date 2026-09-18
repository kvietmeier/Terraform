# Technical checklist

**Brief (multi-region, apply/destroy, Solutions model):** [`README.md`](README.md)

| Pool | SKU | min | Role |
|------|-----|-----|------|
| `system-pool` | `e2-standard-4` | fixed | kube-system (while cluster exists) |
| `apps-pool` | `e2-standard-2` | 0 | Staging |
| `de-team-pool1` | `n4-standard-16` | 0 | CPU-heavy |
| `gpu-l4-pool` | `g2` + L4 | 0 | GPU |

| Ops | Command |
|-----|---------|
| Bring region up | `terraform apply` |
| Full shutdown | `terraform destroy` |
| Between Jobs | scale pods to 0 / timers (pools → 0; control plane remains) |

One cluster per GPU/TPU region (template = this folder). Solutions deploys apps only.
