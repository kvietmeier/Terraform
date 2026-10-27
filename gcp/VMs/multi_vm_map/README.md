# multi_vm_map — unique Linux clients (GCP)

Unique GCE clients from a map. Keys are short names; instance name =
`vm_name_prefix` + key (e.g. `kv-copper`). Shared SSH user **`strata`**.

Mirrors [`aws/ec2/multi_vm_map`](../../../aws/ec2/multi_vm_map/) and
[`azure/VMs/multi_vm_map`](../../../azure/VMs/multi_vm_map/). Identical pool:
[`../multi_vm/`](../multi_vm/).

## Deploy

```bash
cd gcp/VMs/multi_vm_map
cp multi_map.terraform.tfvars.example multi_map.auto.tfvars
# edit project, subnet, vms map (keys = copper, lead, …; set ip_octet)
terraform init && terraform apply
```

## Day-2

Same handoff as [`../multi_vm/`](../multi_vm/): inventory from `vm_private_ips`,
then [ansible](https://github.com/kvietmeier/ansible)
`site.yml --tags client,install_driver`.
