# multi_vm_map — unique Linux clients (AWS)

Root module for **individually specified** EC2 clients. Each map entry sets its
own short name, instance type, disk size, and OS. Shared network, key pair,
tags, and cloud-init.

Mirrors [`gcp/VMs/multi_vm_map`](../../../gcp/VMs/multi_vm_map/) and
[`azure/VMs/multi_vm_map`](../../../azure/VMs/multi_vm_map/). For an identical
pool, use [`../multi_vm/`](../multi_vm/).

## Naming

Map **keys** are short names; instance `Name` = `vm_name_prefix` + key
(default `kv-copper`, `kv-lead`, …). SSH user: **`strata`**.

```hcl
vm_name_prefix = "kv-"
vms = {
  copper = { machine_type = "m6i.2xlarge", bootdisk_size = 256, os_type = "ubuntu" }
  lead   = { machine_type = "m6i.2xlarge", bootdisk_size = 256, os_type = "ubuntu" }
  # …
}
```

## Deploy

```bash
cd aws/ec2/multi_vm_map
cp multi_map.auto.tfvars.example multi_map.auto.tfvars
# edit: subnet, SG, key, tags, vms map

export AWS_PROFILE=your-profile
terraform init && terraform apply
```

## Day-2

Same as [`../multi_vm/`](../multi_vm/): fill ansible inventory from
`vm_private_ips`, then
`ansible-playbook -i inventory.ini site.yml --tags client,install_driver`
([kvietmeier/ansible](https://github.com/kvietmeier/ansible)).
