# vastdata/ — VAST Data provider examples

Working examples for the [VAST Data Terraform provider](https://registry.terraform.io/providers/vast-data/vastdata/latest/docs).

Provider version pinned to **3.2.2**. Auth via env / `TF_VAR_*` (never commit passwords).

## Start here

1. [`simple_query/`](simple_query/) — auth / connectivity smoke test  
2. [`basic_cluster/`](basic_cluster/) — POC baseline (tenants, users, NFS/S3 views)  
3. [`createviews/`](createviews/) or [`lab_share/`](lab_share/) — against an existing VIP pool  

```bash
export TF_VAR_vast_host="192.168.1.100"
export TF_VAR_vast_username="admin"
export TF_VAR_vast_password="YourActualVMSPasswordHere"

cd simple_query
cp sq.auto.tfvars.example sq.auto.tfvars   # if needed
terraform init && terraform apply
```

## Layout

| Directory | Purpose |
|-----------|---------|
| [`provider/`](provider/) | Portable env-driven provider pattern |
| [`simple_query/`](simple_query/) | Login smoke test |
| [`basic_cluster/`](basic_cluster/) | Demo/POC baseline cluster config |
| [`complete_cluster_config/`](complete_cluster_config/) | Full end-to-end config (VIP, DNS, AD, …) |
| [`cluster_gcp/`](cluster_gcp/) | Full-config sibling with GCP-oriented naming |
| [`createviews/`](createviews/) | NFS views/policies on an existing VIP pool |
| [`lab_share/`](lab_share/) | Wide-open NFS+S3 lab dump share (**lab only, not prod**) |
| [`view_template/`](view_template/) | Documented schema reference |
| [`block_volumes/`](block_volumes/) | Block subsystem / volume / host-mapping |
| [`protected_path/`](protected_path/) | Protected-path pattern |
| [`policies/`](policies/) | S3 policy JSON examples ([README](policies/README.md)) |

Provider alias in these examples is `cluster` (not a cloud-specific name).
