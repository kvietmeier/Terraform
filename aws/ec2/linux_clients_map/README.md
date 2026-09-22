# linux_clients_map — unique Linux clients

Root module for **individually specified** EC2 clients. Each map entry sets its own name, instance type, disk size, and OS. Shared network, key pair, tags, and cloud-init.

Mirrors [`gcp/VMs/multi_vm_map`](../../../gcp/VMs/multi_vm_map/). For a large identical client pool, use [`../linux_clients/`](../linux_clients/) (`num_vm`).

## Define VMs

Edit `clients.auto.tfvars`:

```hcl
vms = {
  "voc-bench01" = { machine_type = "m6i.4xlarge", bootdisk_size = 512, os_type = "ubuntu" }
  "voc-jump01"  = { machine_type = "t3.medium",   bootdisk_size = 64,  os_type = "ubuntu" }
  "voc-rocky01" = { machine_type = "m6i.2xlarge", bootdisk_size = 256, os_type = "rocky" }
}
```

Map key = EC2 `Name` tag. `os_type` must match a key in `os_amis`.

## Deploy

```bash
cd aws/ec2/linux_clients_map
# edit clients.auto.tfvars: subnet, SG, key, tags, vms map

export AWS_PROFILE=your-profile
terraform init
terraform apply
```

Requires an existing subnet, security group, and EC2 key pair. Cloud-init path defaults to the shared universal bootstrap under `scripts/cloud-init/`.

## Outputs

- `vm_ids`, `vm_private_ips`
- `ssh_commands`, `serial_console_urls`, `connection_info`

Tag `AutoShutdown=true` (in `common_tags`) to opt into overnight stop — see [`../autoshutdown/`](../autoshutdown/).
