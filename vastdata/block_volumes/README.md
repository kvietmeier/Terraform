# block_volumes/

Block storage lab stack for an **existing** VAST cluster. Creates only our objects - shared tenant, VIP pool, block policy, are lookups.

## What it creates

| Object | Resource | Notes |
|--------|----------|--------|
| Block subsystem view | `vastdata_view` | Shared path for our volumes |
| Host per client | `vastdata_block_host` | One initiator identity per server |
| Volumes | `vastdata_volume` | Size in bytes; naming like `2019_01_vol1` |
| Mappings | `vastdata_block_host_mapping` | One map per volume → its host |

Most initiators use a **standard NQN format** (vendor prefix + hostname or UUID). Set `base_nqn_prefix` in **`private.auto.tfvars`** (gitignored) so each host gets `<prefix>:<hostname>`, or override per host with `hosts.*.nqn`.

```bash
cp private.auto.tfvars.example private.auto.tfvars
# edit base_nqn_prefix — vendor-specific examples: internal GitLab docs
```

Add hosts/volumes in `block.variables.tfvars` and re-apply (idempotent `for_each`). Do not adopt or modify existing lab hosts.

## Files

```text
block.provider.tf              # vastdata 3.2.2; TF_VAR_* / env auth
block.main.tf                  # lookups + view / hosts / volumes / maps
block.variables.tf             # input schema (no defaults)
block.variables.tfvars         # shared lab values (hosts, volumes) — committed
private.auto.tfvars.example    # copy → private.auto.tfvars for NQN prefix
private.auto.tfvars            # local NQN prefix — gitignored
block.outputs.tf               # subsystem / hosts / volumes / summary
```

## Usage

```bash
# Export VMS auth (TF_VAR_vast_host, TF_VAR_vast_username, TF_VAR_vast_password, …)
export TF_VAR_vast_host="192.168.1.100"
export TF_VAR_vast_username="admin"
export TF_VAR_vast_password="YourActualVMSPasswordHere"

terraform init
terraform plan
terraform apply
terraform output summary
```

`*.tfvars` in this directory are picked up automatically.
