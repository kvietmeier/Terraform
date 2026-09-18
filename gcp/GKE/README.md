# gcp/GKE/

| Directory | Purpose |
|-----------|---------|
| [`gke-aicluster/`](gke-aicluster/) | Regional lab cluster template — Solutions deploys apps; platform `apply`/`destroy`. [Brief →](gke-aicluster/README.md) |
| [`gke-testing/`](gke-testing/) | Older experiment — not the reference |
| [`kubernetes/`](kubernetes/) | Sample manifests |

## Model

- **Solutions:** deploy apps only (`kubectl`); no cluster create.  
- **Platform:** one cluster **per accelerator region** (colocate with GPU/TPU); scale-from-zero pools; **`terraform destroy`** when a region is idle.  
- **Worst case for Solutions:** request a new pool SKU, or ask platform to bring a region up.

Full story: **[`gke-aicluster/README.md`](gke-aicluster/README.md)**.
