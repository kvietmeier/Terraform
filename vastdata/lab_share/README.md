# lab_share/

Terraform equivalent of [`vastops/create_lab_share.py`](../../../vastops/create_lab_share.py): a **wide-open** multiprotocol dump share for lab testing.

**Not for customer production** — RW `*`, no squash, loose SMB modes.

## What it creates

| Object | Resource | Default |
|--------|----------|---------|
| View policy | `vastdata_view_policy.lab` | `lab_policy` (NFS flavor, LCD, LINUX gid) |
| View | `vastdata_view.lab_share` | path `/lab_share`, protocols NFS+S3 |
| Local user | `vastdata_user.lab` | `lab` (uid 50000) as S3 `bucket_owner` when S3 is enabled |
| VIP pool | `data.vastdata_vip_pool.protocols` | lookup `protocolsPool` (cloud Stage 1); bind via `permission_per_vip_pool` |

Tenant `default` is a **lookup** only; the view is pinned with `tenant_id`.
VIP pool is also a **lookup** only — never created here.

## Protocols

| `protocols` | Notes |
|-------------|--------|
| `["NFS", "S3"]` (default) | Matches the Python script; no AD required |
| `["NFS", "SMB", "S3"]` | SMB needs an AD provider with SMB allowed |
| `["NFS"]` / `["S3"]` | Single-protocol lab variants |

## Files

```text
lab.provider.tf         # vastdata 3.2.2; TF_VAR_* / env auth
lab.main.tf             # tenant lookup + user + policy + view
lab.variables.tf        # inputs (defaults match create_lab_share.py)
lab.variables.tfvars    # committed lab defaults
lab.outputs.tf          # lab_share summary map
```

## Usage

```bash
export TF_VAR_vast_host = "192.168.1.100"
export TF_VAR_vast_username="admin"
export TF_VAR_vast_password = "CHANGE_ME"

cd terraform/vast/lab_share
terraform init
terraform plan -var-file=lab.variables.tfvars
terraform apply -var-file=lab.variables.tfvars
```

If the Python script already created `lab_policy` / `/lab_share` / user `lab`, import them before apply (or destroy the hand-built objects first).

## Relation to vastops

`create_lab_share.py` remains a quick CLI dry-run/`--apply` helper. Prefer this stack when you want state-managed lab shares.
