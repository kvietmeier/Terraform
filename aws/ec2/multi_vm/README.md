# multi_vm — identical Linux client pool (AWS)

Root module for a **scaled pool of identical** EC2 clients. Same instance type,
disk, OS, and cloud-init for every VM.

Mirrors [`gcp/VMs/multi_vm`](../../../gcp/VMs/multi_vm/) and
[`azure/VMs/multi_vm`](../../../azure/VMs/multi_vm/). For mixed sizes / OS per
host, use [`../multi_vm_map/`](../multi_vm_map/).

## Naming

| Mode | Vars | Example names |
|------|------|---------------|
| Named list (demo default) | `vm_name_prefix` + `vm_names` | `kv-copper` … `kv-gold` |
| Numbered | `vm_name_prefix` + `vm_base_name` + `vm_count` | `kv-linux01`, `kv-linux02`, … |

SSH / Ansible user: **`strata`** (universal cloud-init).

## Deploy

```bash
cd aws/ec2/multi_vm
cp multi.auto.tfvars.example multi.auto.tfvars
# edit: subnet, SG, key, tags, vm_names or vm_count

export AWS_PROFILE=your-profile
terraform init && terraform apply
```

Requires an existing subnet, security group, and EC2 key pair. Cloud-init:
[`scripts/cloud-init/cloud-init-universal.yaml`](../../../scripts/cloud-init/cloud-init-universal.yaml).

## Outputs (Ansible handoff)

- `vm_names`, `vm_private_ips`, `vm_ids`
- `ssh_commands`, `serial_console_urls`, `connection_info`

Copy private IPs into [ansible `inventory.ini`](https://github.com/kvietmeier/ansible/blob/main/inventory.ini) (`ansible_ssh_user=strata`).

## Day-2 — POC / demo ready

Cloud-init installs NFS *packages* only. Install the VAST NFS kernel driver +
client polish with [kvietmeier/ansible](https://github.com/kvietmeier/ansible):

```bash
ansible-playbook -i inventory.ini site.yml --tags client,install_driver
# optional: --tags mountprep  or  mount_now -e '...'
```

Tag `AutoShutdown=true` (in `common_tags`) to opt into overnight stop — see
[`../autoshutdown/`](../autoshutdown/).
