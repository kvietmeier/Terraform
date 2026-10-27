# multi_vm — identical Linux client pool (GCP)

Creates N private-only GCE VMs with shared cloud-init, a single SSH user
(**`strata`**), subnet, and SA. No public IP (IAP / bastion).

Mirrors [`aws/ec2/multi_vm`](../../../aws/ec2/multi_vm/) and
[`azure/VMs/multi_vm`](../../../azure/VMs/multi_vm/). Unique per-VM specs:
[`../multi_vm_map/`](../multi_vm_map/).

## Naming

| Mode | Vars | Example names |
|------|------|---------------|
| Named list (demo default) | `vm_name_prefix` + `vm_names` | `kv-copper` … `kv-gold` |
| Numbered | `vm_name_prefix` + `vm_base_name` + `vm_count` | `kv-linux01`, … |

One metadata SSH user on every host (`ssh_user = "strata"`) — not per-VM `labuserNN`.

## Deploy

```bash
cd gcp/VMs/multi_vm
cp multi.auto.tfvars.example multi.auto.tfvars
# edit project_id, subnet, sa, keys, vm_names
terraform init && terraform apply
```

Cloud-init: [`scripts/cloud-init/cloud-init-universal.yaml`](../../../scripts/cloud-init/cloud-init-universal.yaml).

Optional static private IPs: `assign_static_ip = true` + `ip_start_offset`.

## Outputs (Ansible handoff)

- `vm_names`, `vm_private_ips`, `vm_users`
- IAP `ssh_commands`

## Day-2 — POC / demo ready

```bash
# after filling inventory.ini from vm_private_ips
ansible-playbook -i inventory.ini site.yml --tags client,install_driver
```

Day-2 roles: [kvietmeier/ansible](https://github.com/kvietmeier/ansible)
(`vast_client` + `vast_nfs`). Access: `gcloud compute ssh strata@kv-copper --tunnel-through-iap …`.
