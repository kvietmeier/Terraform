# GCP BIND mini networking node

Same wrench as [`aws/ec2/bind_forwarder/`](../../../aws/ec2/bind_forwarder/): a **tiny** Ubuntu GCE VM that runs **BIND9** as a VAST conditional DNS forwarder when you **cannot** update Cloud DNS private forwarding zones.

Cloud-init is **shared** — do not copy it here:

[`scripts/cloud-init/cloud-init-bind.yaml.tftpl`](../../../scripts/cloud-init/cloud-init-bind.yaml.tftpl)

| Knob | Example | Meaning |
|------|---------|---------|
| `vast_zones` | `["cluster.example.com"]` | Domain(s) sent to VAST |
| `vast_dns_ips` | `["192.168.1.50"]` | VAST DNS VIP(s) |

```text
Client  --(vast zone)-->  BIND VM  --forward-->  VAST DNS VIP
Client  --(other)------>  BIND VM  --forward-->  169.254.169.254 (GCP)
```

## Deploy

```bash
cd gcp/VMs/bind_forwarder
cp bind.auto.tfvars.example bind.auto.tfvars
# edit: project_id, subnet_name, vpc_cidr, sa_email, ssh_key_file
# after cluster up: vast_zones, vast_dns_ips

terraform init && terraform apply
```

Existing VPC firewall must allow **UDP/TCP 53** to tag `bind-vast-forwarder` (and SSH/IAP as needed).

## Sisters

- AWS: [`aws/ec2/bind_forwarder/`](../../../aws/ec2/bind_forwarder/)
- Azure: [`azure/VMs/bind_forwarder/`](../../../azure/VMs/bind_forwarder/)
