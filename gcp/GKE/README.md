# gcp/GKE/

| Directory | Purpose |
|-----------|---------|
| [`gke-aicluster/`](gke-aicluster/) | **Shared lab cluster** — Solutions deploys apps; platform owns Terraform. [IT / Solutions brief →](gke-aicluster/README.md) |
| [`gke-testing/`](gke-testing/) | Older experiment — not the reference |
| [`kubernetes/`](kubernetes/) | Sample manifests |

## Model for Solutions

- **Do not create GKE clusters.** Use the shared AI/lab cluster.  
- **Deploy apps** (`kubectl apply`), stage on `apps-pool`, then GPU/CPU as needed.  
- **Worst case:** request platform to **add a node pool / instance type** (still `min=0`).  
- Scale to zero / use the timer examples when done.

Full story + diagrams: **[`gke-aicluster/README.md`](gke-aicluster/README.md)**.
