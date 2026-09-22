# linux_clients — identical Linux client pool

Root module for a **scaled pool of identical** Ubuntu (or other) EC2 clients. Same instance type, disk, OS, and cloud-init for every VM. Names are generated as `{vm_base_name}01`, `02`, …

Mirrors [`gcp/VMs/multi_vm`](../../../gcp/VMs/multi_vm/). For mixed sizes / OS per host, use [`../linux_clients_map/`](../linux_clients_map/).

## Scale

Edit `clients.auto.tfvars`:

```hcl
num_vm        = 3
vm_base_name  = "voc-client"
machine_type  = "m6i.2xlarge"
bootdisk_size = 256
os_type       = "ubuntu"
```

Bump `num_vm` to grow the pool.

## Deploy

```bash
cd aws/ec2/linux_clients
# edit clients.auto.tfvars: subnet, SG, key, tags, pool size

export AWS_PROFILE=your-profile
terraform init
terraform apply
```

Requires an existing subnet, security group, and EC2 key pair. Cloud-init path defaults to the shared universal bootstrap under `scripts/cloud-init/`.

## Outputs

- `vm_names`, `vm_ids`, `vm_private_ips`
- `ssh_commands`, `serial_console_urls`, `connection_info`

Tag `AutoShutdown=true` (in `common_tags`) to opt into overnight stop — see [`../autoshutdown/`](../autoshutdown/).
