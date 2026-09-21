# AWS BIND DNS Forwarder (mini networking node)

Tiny Ubuntu EC2 whose **only job** is BIND9 conditional forwarding for VAST VIP-pool DNS when Route 53 Resolver / DHCP option sets are unavailable.

Mini networking node: **Ubuntu + BIND9** (VAST conditional forwarder) with a minimized net-tools set. Default `ubuntu` user; basic aliases + `set -o vi`. Uses an **existing security group**. Keep it **tiny** (`t3.micro` / nano) so cost stays quiet — and tag `AutoShutdown=true` so after-hours lab stop can catch it (see `../autoshutdown/`). Edit `vast_zones` / `vast_dns_ips` after the cluster is up (not useful OOB).

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

Terraform applies `common_tags` from tfvars, plus always `vast-client=true`, `Role=bind-vast-forwarder`, and `Name`.

Example only (edit values / instance id as needed):

```bash
aws ec2 create-tags \
  --region us-west-2 \
  --resources i-0123456789abcdef0 \
  --tags \
    Key=vast-client,Value=true \
    Key=Name,Value=bind-vast-fwd \
    Key=Role,Value=bind-vast-forwarder
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
