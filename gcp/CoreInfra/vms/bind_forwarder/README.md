# CoreInfra — BIND mini networking node (GCP)

Tiny Ubuntu GCE VM running **BIND9** as a VAST conditional DNS forwarder when you **cannot** update Cloud DNS private forwarding zones.

Canonical location: **`gcp/CoreInfra/vms/bind_forwarder/`** (not under `gcp/VMs/`).

Cloud-init is **shared** — do not copy it:

[`scripts/cloud-init/cloud-init-bind.yaml.tftpl`](../../../../scripts/cloud-init/cloud-init-bind.yaml.tftpl)

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
cd gcp/CoreInfra/vms/bind_forwarder
cp bind.auto.tfvars.example bind.auto.tfvars
# edit: project_id, network_name, subnet_name, vpc_cidr, sa_email, ssh_key_file
# placeholders OK for first boot; set vast_zones + vast_dns_ips after cluster up

terraform init && terraform apply
```

Default: private-only NIC, cloud-assigned IP, IAP SSH. Optional FW rule (`enable_dns_firewall`) allows UDP/TCP **53** from `vpc_cidr` to tag `bind-vast-forwarder`.

## Verify

```bash
terraform output ssh_command
# then on the VM:
sudo named-checkconf /etc/bind/named.conf
sudo systemctl status bind9
dig @localhost google.com
dig @localhost something.cluster.example.com   # after vast_* knobs are real

terraform output verify_commands
terraform output client_resolv_snippet   # for client01–03
```

## Sisters

- AWS: [`aws/ec2/bind_forwarder/`](../../../../aws/ec2/bind_forwarder/)
- Azure: [`azure/VMs/bind_forwarder/`](../../../../azure/VMs/bind_forwarder/)
- Older GCP path (redirect): [`gcp/VMs/bind_forwarder/`](../../../VMs/bind_forwarder/)
