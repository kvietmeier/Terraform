# multi_vm_map — unique Linux clients (Azure)

Unique Azure Linux HPC clients from a map. Keys are short names; VM name =
`vm_name_prefix` + key. Shared SSH user **`strata`**.

Mirrors [`aws/ec2/multi_vm_map`](../../../aws/ec2/multi_vm_map/) and
[`gcp/VMs/multi_vm_map`](../../../gcp/VMs/multi_vm_map/). Identical pool:
[`../multi_vm/`](../multi_vm/).

## Deploy

```bash
cd azure/VMs/multi_vm_map
cp multi_map.auto.tfvars.example multi_map.auto.tfvars
# edit networking + vms map
az vm image terms accept --urn "azure-hpc:azurelinux-hpc:3:latest"   # once
terraform init && terraform apply
```

## Day-2

Inventory from `vm_public_ips` / `vm_private_ips`, then
[ansible](https://github.com/kvietmeier/ansible)
`site.yml --tags client,install_driver`.
