# Multi VM (lab clients)

Creates N private-only GCE VMs (default: 3× Ubuntu 24.04) with shared cloud-init, SSH keys, subnet, and SA.

Same networking pattern as [`gcp/CoreInfra/vms/devops`](../../CoreInfra/vms/devops): no public IP, cloud-assigned private IP, IAP SSH.

## Deploy

```bash
cd gcp/VMs/multi_vm
cp multi.auto.tfvars.example multi.auto.tfvars
# edit project_id, subnet, sa, keys
terraform init && terraform apply
```

## Defaults

| Setting | Value |
|---------|--------|
| Count / names | `labuser01` … `labuser0N` |
| Image | `ubuntu-os-cloud/ubuntu-2404-lts-amd64` |
| Labels | `used` / `owned_by` (set in tfvars) |
| Cloud-init | [`scripts/cloud-init/cloud-init-universal.yaml`](../../../scripts/cloud-init/cloud-init-universal.yaml) |

Optional static private IPs: `assign_static_ip = true` + `ip_start_offset`.
