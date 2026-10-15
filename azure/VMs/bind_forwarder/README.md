# Azure BIND mini networking node

Same wrench as [`aws/ec2/bind_forwarder/`](../../../aws/ec2/bind_forwarder/): a **tiny** Ubuntu VM that runs **BIND9** as a VAST conditional DNS forwarder when you **cannot** update Azure Private DNS / vNet custom DNS.

Cloud-init is **shared** — do not copy it here:

[`scripts/cloud-init/cloud-init-bind.yaml.tftpl`](../../../scripts/cloud-init/cloud-init-bind.yaml.tftpl)

| Knob | Example | Meaning |
|------|---------|---------|
| `vast_zones` | `["cluster.example.com"]` | Domain(s) sent to VAST |
| `vast_dns_ips` | `["192.168.1.50"]` | VAST DNS VIP(s) |

```text
Client  --(vast zone)-->  BIND VM  --forward-->  VAST DNS VIP
Client  --(other)------>  BIND VM  --forward-->  168.63.129.16 (Azure)
```

## Deploy

```bash
cd azure/VMs/bind_forwarder
cp bind.auto.tfvars.example bind.auto.tfvars
# edit: location, network RG/vNet/subnet, vnet_cidr, ssh key
# after cluster up: vast_zones, vast_dns_ips

terraform init && terraform apply
```

Existing NSG (optional `nsg_id`) must allow **UDP/TCP 53** from clients and egress DNS to the VAST VIP + Azure wire server.

## Sisters

- AWS: [`aws/ec2/bind_forwarder/`](../../../aws/ec2/bind_forwarder/)
- GCP: [`gcp/VMs/bind_forwarder/`](../../../gcp/VMs/bind_forwarder/)
