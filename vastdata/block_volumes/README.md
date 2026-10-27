# block_volumes/

Block storage lab stack for an **existing** VAST cluster. Creates only our objects - shared tenant, VIP pool, block policy, are lookups.

## Views and subsystems

In VAST block, **subsystem ≈ view**.

A BLOCK **view** *is* the NVMe-oF **subsystem** (target side): it has a path, a name, and a **target NQN**. Volumes live *inside* that view. Hosts (initiators) map to those volumes.

```text
initiator host (lab-client01, NQN …)
    ↕ mapped to
volumes (2022_01_vol1, vol2)
    ↕ live under
subsystem / view (lab-client01_block, path=/lab-client01_block, target NQN …)
```

| Terraform | VAST concept |
|-----------|----------------|
| `vastdata_view` | Block subsystem |
| `vastdata_volume` | LUN/volume in that subsystem |
| `vastdata_block_host` | Initiator (client) |
| `vastdata_block_host_mapping` | Which host can see which volume |

That is why this stack uses **one view per host**: each client gets its own subsystem, then its volumes, then the maps — not one shared subsystem for everyone.

## What it creates

Hierarchical map keyed by initiator hostname:

**host → subsystem (view) → volumes → mapping**

| Object | Resource | Notes |
|--------|----------|--------|
| Block subsystem view | `vastdata_view` | One per host (`<hostname>_block` by default) |
| Host per client | `vastdata_block_host` | One initiator identity per server |
| Volumes | `vastdata_volume` | Nested under that host; naming like `2019_01_vol1` |
| Mappings | `vastdata_block_host_mapping` | One map per volume → its host |

Most initiators use a **standard NQN format** (vendor prefix + hostname or UUID). Set `base_nqn_prefix` in **`private.auto.tfvars`** (gitignored) so each host gets `<prefix>:<hostname>`, or override per host with `hosts.*.nqn`.

```bash
cp private.auto.tfvars.example private.auto.tfvars
# edit base_nqn_prefix — vendor-specific examples: internal GitLab docs
```

Add a host map entry (with nested `volumes`) in `block.variables.tfvars` and re-apply. Do not adopt or modify existing lab hosts.

## Files

```text
block.provider.tf              # vastdata 3.2.2; TF_VAR_* / env auth
block.main.tf                  # lookups + per-host view / host / volumes / maps
block.variables.tf             # input schema (no defaults)
block.variables.tfvars         # hosts map with nested volumes — committed
private.auto.tfvars.example    # copy → private.auto.tfvars for NQN prefix
private.auto.tfvars            # local NQN prefix — gitignored
block.outputs.tf               # block map keyed by host
```

## Usage

```bash
# Export VMS auth (TF_VAR_vast_host, TF_VAR_vast_username, TF_VAR_vast_password, …)
export TF_VAR_vast_host = "192.168.1.100"
export TF_VAR_vast_username="admin"
export TF_VAR_vast_password = "CHANGE_ME"

terraform init
terraform plan
terraform apply
terraform output block
```

`*.tfvars` in this directory are picked up automatically.
