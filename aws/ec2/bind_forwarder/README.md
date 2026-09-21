# AWS BIND mini networking node

An SRE toolbox wrench: a **tiny** Ubuntu EC2 that runs **BIND9** as a VAST conditional DNS forwarder, plus a minimized set of standard Linux network debug tools (`dig`, `tcpdump`, `nmap`, `mtr`, …).

Use it when you cannot change Route 53 Resolver / DHCP option sets, but still need clients to resolve VAST VIP-pool names. Cheap enough to leave up (`t3.micro`); tag `AutoShutdown=true` so overnight lab stop can catch it (see [`../autoshutdown/`](../autoshutdown/)).

Not useful OOB — after the cluster is up, set the two knobs and point test clients at this VM.

| Knob | Example | Meaning |
|------|---------|---------|
| `vast_zones` | `["busab.org"]` | Domain(s) sent to VAST |
| `vast_dns_ips` | `["10.105.28.250"]` | VAST DNS VIP(s) |

Everything else is wiring: existing subnet + SG (same pattern as `tux_clients`), key pair, VPC CIDR for BIND’s query ACL.

## What’s on the box

- Stock Ubuntu AMI, user `ubuntu` (cloud key pair as usual)
- BIND9 + `bind9utils` / `dnsutils`
- Net tools: `ip`/`ss`, ping, traceroute, mtr, tcpdump, nmap, curl/wget
- Light QoL: vim, jq, python3, htop, tmux; basic aliases + `set -o vi`
- No labuser, no bench-tool compiles — add packages later if needed (`sudo apt install netcat-openbsd`, etc.)

## Deploy

```bash
cd aws/ec2/bind_forwarder
cp bind.auto.tfvars.example bind.auto.tfvars
# edit: subnet_id, security_group_ids, vpc_cidr, ssh_key_name
# after cluster up: vast_zones, vast_dns_ips

export AWS_PROFILE=your-profile
terraform init
terraform apply
```

Existing SG must allow **UDP/TCP 53** from clients and egress DNS to the VAST VIP + VPC resolver (`169.254.169.253`).

## How it works

```text
Client  --(vast zone)-->  BIND VM  --forward-->  VAST DNS VIP
Client  --(other)------>  BIND VM  --forward-->  169.254.169.253 (AWS)
```

DHCP option sets are not changed — override DNS on test clients only.

### Client override (systemd-resolved)

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

### Verify on the BIND VM

```bash
sudo named-checkconf /etc/bind/named.conf
sudo systemctl status bind9
sudo ss -tulpn | grep :53

dig @localhost mycluster.busab.org
dig @localhost google.com
```

## Tags

Terraform merges `common_tags` with always-on `vast-client=true`, `Role=bind-vast-forwarder`, and `Name`.

Example only:

```bash
aws ec2 create-tags \
  --region us-west-2 \
  --resources i-0123456789abcdef0 \
  --tags \
    Key=vast-client,Value=true \
    Key=Name,Value=bind-vast-fwd \
    Key=Role,Value=bind-vast-forwarder
```

## Files

| File | Role |
|------|------|
| `bind.main.tf` | AMI + EC2 + cloud-init + tags |
| `cloud-init-bind.yaml.tftpl` | BIND + net tools + named.conf |
| `bind.auto.tfvars.example` | Copy → local `bind.auto.tfvars` (gitignored) |

Real tfvars: keep local / backup with `scripts/sync-tfvars-personal.sh`.

## Author

Karl Vietmeier — Apache 2.0
