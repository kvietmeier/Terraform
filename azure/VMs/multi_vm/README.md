# multi_vm — identical Linux client pool (Azure)

Azure Linux HPC client fleet (NVMe, UltraSSD, proximity placement group).
Mirrors [`aws/ec2/multi_vm`](../../../aws/ec2/multi_vm/) and
[`gcp/VMs/multi_vm`](../../../gcp/VMs/multi_vm/). Unique per-VM sizes:
[`../multi_vm_map/`](../multi_vm_map/).

## Naming

| Mode | Vars | Example names |
|------|------|---------------|
| Named list (demo default) | `vm_name_prefix` + `vm_names` | `kv-copper` … `kv-gold` |
| Numbered | `vm_name_prefix` + `vm_base_name` + `vm_count` | `kv-linux01`, … |

Admin / Ansible user: **`strata`**.

## One-time Marketplace accept

```bash
az vm image terms accept --urn "azure-hpc:azurelinux-hpc:3:latest"
```

## Deploy

```bash
cd azure/VMs/multi_vm
cp multi.auto.tfvars.example multi.auto.tfvars
# edit RG, vNet/subnet, ssh key, vm_names
terraform init && terraform apply
```

Cloud-init: [`scripts/cloud-init/cloud-init-universal.yaml`](../../../scripts/cloud-init/cloud-init-universal.yaml).

## Outputs (Ansible handoff)

- `vm_names`, `vm_public_ips`, `vm_private_ips`, `ssh_commands`

Prefer public IPs for inventory when VMs are Internet-reachable.

## Day-2 — POC / demo ready

```bash
ansible-playbook -i inventory.ini site.yml --tags client,install_driver
```

[kvietmeier/ansible](https://github.com/kvietmeier/ansible) — `vast_client` + `vast_nfs`.

### Azure Linux notes

- Package manager: `tdnf` (RPM-family; ansible `vast_nfs` RHEL path applies).
- Secure boot defaults off so unsigned drivers can load.
