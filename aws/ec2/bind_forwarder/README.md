# AWS BIND DNS Forwarder (tiny VM)

Tiny Ubuntu EC2 whose **only job** is BIND9 conditional forwarding for VAST VIP-pool DNS when Route 53 Resolver / DHCP option sets are unavailable.

Minimal QoL (vim, jq, curl, dig, aliases, `set -o vi`) — not a general lab client.

Most of the time you only change two values in tfvars:

| Knob | Example | Meaning |
|------|---------|---------|
| `vast_zones` | `["busab.org"]` | Domain(s) sent to VAST |
| `vast_dns_ips` | `["10.105.28.250"]` | VAST DNS VIP(s) |

Everything else (VPC, subnet, key pair) is normal lab wiring. Non-VAST queries are forwarded to the AWS VPC resolver (`169.254.169.253`).

## Why a tiny VM?

A forwarder does almost no work — `t3.micro` (or even `t3.nano`) is enough. This is a lab hack, not a replacement for Route 53 inbound/outbound endpoints.

## Deploy

```bash
cd aws/ec2/bind_forwarder
cp bind.auto.tfvars.example bind.auto.tfvars
# edit: vpc_id, subnet_id, vpc_cidr, ssh_key_name, vast_zones, vast_dns_ips

export AWS_PROFILE=your-profile   # or use default credential chain
terraform init
terraform apply
```

Outputs include the forwarder private IP and a ready-made client `resolved.conf` snippet.

## How it works

```text
Client  --(busab.org)-->  BIND VM  --forward-->  VAST DNS VIP
Client  --(other)------>  BIND VM  --forward-->  169.254.169.253 (AWS)
```

You cannot push this BIND IP via DHCP option sets without affecting the whole VPC, so **clients must be pointed at it** (full resolver, or selective `Domains=~zone`).

## Client override (systemd-resolved)

On Ubuntu/RHEL clients, create:

```ini
# /etc/systemd/resolved.conf.d/vast-forwarder.conf
[Resolve]
DNS=<BIND_PRIVATE_IP>
Domains=~busab.org
```

Then:

```bash
sudo systemctl restart systemd-resolved
resolvectl query mycluster.busab.org
```

`Domains=~busab.org` routes **only** that zone to BIND; other names stay on the normal VPC DNS. If you instead set the client’s sole `DNS=` to the BIND IP (no `~` routing), BIND must recurse everything — this stack already forwards unmatched queries to `169.254.169.253`.

## Verify on the BIND VM

```bash
sudo named-checkconf /etc/bind/named.conf
sudo systemctl status bind9   # or named
sudo ss -tulpn | grep :53

dig @localhost mycluster.busab.org
dig @localhost google.com
```

## Network checklist

Security group created by this stack:

| Direction | Proto/Port | Source / Dest |
|-----------|------------|---------------|
| Inbound | UDP/TCP 53 | `vpc_cidr` (+ optional extras) |
| Inbound | TCP 22 | `ssh_cidr` or `vpc_cidr` |
| Outbound | UDP/TCP 53 | each `vast_dns_ips` + `cloud_resolver` |
| Outbound | TCP 80/443 | `0.0.0.0/0` (apt) |

## Files

| File | Role |
|------|------|
| `bind.main.tf` | AMI + EC2 + cloud-init |
| `bind.network.tf` | Security group |
| `cloud-init-bind.yaml.tftpl` | Installs BIND, writes zone + options |
| `bind.auto.tfvars.example` | Copy → `bind.auto.tfvars` |

## Author

Karl Vietmeier — Apache 2.0
