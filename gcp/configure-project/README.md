# Configure GCP Project (consolidated CoreInfra)

Single root module that wires the production pieces from `gcp/CoreInfra` into one apply.
**`gcp/CoreInfra` is left unchanged** — this folder is the roll-up.

## Layout

```text
gcp/configure-project/
├── main.tf / variables.tf / outputs.tf / versions.tf / locals.tf
├── terraform.tfvars.example
└── modules/
    ├── vpc/                 ← CoreInfra/vpcs/core
    ├── firewalls/           ← CoreInfra/firewalls/my_rules
    ├── dns/
    │   ├── private_zone/    ← CoreInfra/DNS/my_domains
    │   ├── ad_forwarder/    ← CoreInfra/DNS/AD-Forwarder
    │   └── vast_forwarders/ ← CoreInfra/DNS/vast_forwarders
    ├── vpn_gw/              ← CoreInfra/vpn_gw
    ├── vms/{linux,windows}  ← CoreInfra/vms/devops + w22server
    └── iap/                 ← CoreInfra/IAPSetup
```

## Apply graph

```text
vpc  →  firewalls
     →  dns (private + vast forwarders)
     →  vpn (optional)
     →  linux / windows VMs (optional)
     →  AD DNS forwarder (after DC IP known)
     →  IAP (optional, last)
```

## Usage

```bash
cd gcp/configure-project
cp terraform.tfvars.example terraform.tfvars   # or private.auto.tfvars
# edit project_id, feature flags, secrets

terraform init
terraform plan
terraform apply
```

Feature flags (defaults favor network + DNS; VMs/VPN/IAP off until configured):

| Flag | Default | Source |
|------|---------|--------|
| `enable_firewalls` | true | `firewalls/my_rules` |
| `enable_dns_private` | true | `DNS/my_domains` |
| `enable_dns_ad_forwarder` | true | `DNS/AD-Forwarder` |
| `enable_dns_vast_forwarders` | true | `DNS/vast_forwarders` |
| `enable_vpn` | false | `vpn_gw` |
| `enable_linux_vms` | false | `vms/devops` |
| `enable_windows_vms` | false | `vms/w22server` |
| `enable_iap` | false | `IAPSetup` |

## Not included (on purpose)

- Lab stacks: `firewalls/wide_open`, `open_ports`, `vpcs/testvpc01`
- `NAT_GW` (NAT already comes from `vpcs/core`)
- VMs on the `default` VPC (`linux_vm`, `ad_server`)
- `vpcs/spoke1` (add later if needed)
- Azure CoreInfra (out of scope)

## State

Uses local state by default. Optional GCS backend is commented in `versions.tf` —
use a **new** prefix so you do not collide with existing CoreInfra state objects.

## Improvements vs piece-by-piece roots

- One provider pin (`>= 5.9`)
- VPC outputs (`network_id`, `subnet_self_links`) fed into VMs/DNS instead of hardcoded names
- VPN VIP advertise ranges are variables
- Secrets stay in tfvars / outside git (example uses `CHANGE_ME`)
