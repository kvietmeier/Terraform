# block_volumes/

Block storage lab stack for an **existing** VAST cluster. Creates only our objects; shared tenant / VIP pool / block policy are lookups.

## What it creates

| Object | Resource | Notes |
|--------|----------|--------|
| Block subsystem view | `vastdata_view` | Shared path for our volumes |
| Host per client | `vastdata_block_host` | One initiator identity per server |
| Volumes | `vastdata_volume` | Size in bytes; naming like `2019_01_vol1` |
| Mappings | `vastdata_block_host_mapping` | One map per volume → its host |

Most initiators use a **standard NQN format** (vendor prefix + hostname or UUID). Set `base_nqn_prefix` in tfvars so each host gets `<prefix>:<hostname>`, or override per host with `hosts.*.nqn`.

Vendor-specific NQN examples (and lab client notes) live in **internal GitLab docs** — this public tree keeps a generic placeholder prefix so the pattern stays reusable without exposing those details.

Add hosts/volumes in `block.variables.tfvars` and re-apply (idempotent `for_each`). Do not adopt or modify existing lab hosts.

## Files

```text
block.provider.tf       # vastdata 3.2.2; TF_VAR_* auth from set_var54
block.main.tf           # lookups + view / hosts / volumes / maps
block.variables.tf      # input schema (no defaults)
block.variables.tfvars  # lab values (NQN prefix, hosts, volumes)
block.outputs.tf        # subsystem / hosts / volumes / summary
```

## Usage

```bash
source ~/.bash_environment.sh   # or your usual env
set_var54
tfinit
tfplan
tfapply
terraform output summary
```

`tfplan` / `tfapply` pick up `*.tfvars` automatically via your wrappers.
