# AWS BIND DNS Forwarder (tiny VM)

Tiny Ubuntu EC2 whose **only job** is BIND9 conditional forwarding for VAST VIP-pool DNS when Route 53 Resolver / DHCP option sets are unavailable.

Uses an **existing security group** (same pattern as `tux_clients`). Minimal QoL only (vim, jq, curl, dig, aliases, `set -o vi`).

Most of the time you only change two values in tfvars:

| Knob | Example | Meaning |
|------|---------|---------|
| `vast_zones` | `["busab.org"]` | Domain(s) sent to VAST |
| `vast_dns_ips` | `["10.105.28.250"]` | VAST DNS VIP(s) |

## Deploy

```bash
cd aws/ec2/bind_forwarder
cp bind.auto.tfvars.example bind.auto.tfvars
# edit: subnet_id, security_group_ids, vpc_cidr, ssh_key_name, vast_zones, vast_dns_ips

export AWS_PROFILE=your-profile
terraform init
terraform apply
```

Ensure the existing SG allows **UDP/TCP 53** from clients and egress to the VAST VIP + VPC resolver (`169.254.169.253`).

## Tags

Terraform applies standard Solutions IT tags from `common_tags`, plus always:

| Key | Value |
|-----|-------|
| `vast-client` | `true` |
| `Role` | `bind-vast-forwarder` |
| `Name` | `instance_name` |

### Update tags with AWS CLI

After apply (or to fix tags on an existing instance):

```bash
# Replace INSTANCE_ID / NAME as needed (terraform output tag_update_command prints this filled in)
aws ec2 create-tags \
  --region us-west-2 \
  --resources i-0123456789abcdef0 \
  --tags \
    Key=UsedBy,Value=solutions \
    Key=used_by,Value=solutions \
    Key=owned,Value=solutions \
    Key=longrun,Value=yes \
    Key=Project,Value=VoC \
    Key=Environment,Value=lab \
    Key=Lifecycle,Value=demo \
    Key=vast-client,Value=true \
    Key=Name,Value=bind-vast-fwd \
    Key=Role,Value=bind-vast-forwarder
```

Or use the Terraform output:

```bash
terraform output -raw tag_update_command | bash
```

## How it works

```text
Client  --(busab.org)-->  BIND VM  --forward-->  VAST DNS VIP
Client  --(other)------>  BIND VM  --forward-->  169.254.169.253 (AWS)
```

Clients must be pointed at this BIND IP (full resolver, or selective `Domains=~zone`) — DHCP option sets are not changed.

## Client override (systemd-resolved)

```ini
# /etc/systemd/resolved.conf.d/vast-forwarder.conf
[Resolve]
DNS=<BIND_PRIVATE_IP>
Domains=~busab.org
```

```bash
sudo systemctl restart systemd-resolved
resolvectl query mycluster.busab.org
```

## Verify on the BIND VM

```bash
sudo named-checkconf /etc/bind/named.conf
sudo systemctl status bind9   # or named
sudo ss -tulpn | grep :53

dig @localhost mycluster.busab.org
dig @localhost google.com
```

## Files

| File | Role |
|------|------|
| `bind.main.tf` | AMI + EC2 + cloud-init + tags |
| `cloud-init-bind.yaml.tftpl` | Installs BIND, writes zone + options |
| `bind.auto.tfvars.example` | Copy → `bind.auto.tfvars` |

## Author

Karl Vietmeier — Apache 2.0
