# azure/

Terraform stacks for Azure lab and POC infrastructure: shared networking/identity, VMs, AKS, and AVD.

## Layout

```text
azure/
├── CoreInfra/     # Shared infra (vNets, NSG, AADDS, VPN, storage, users)
├── VMs/           # Linux / Windows / multi-VM / benchmarking
├── AKS/           # AKS cluster examples
├── AVD/           # Azure Virtual Desktop experiments
├── templates/     # Reusable snippets / starters
└── testing/       # Scratch / experimental modules
```

| Directory | Purpose |
|-----------|---------|
| [`CoreInfra/`](CoreInfra/) | vNets, NSGs, Azure AD DS, VPN gateway, storage, user management |
| [`VMs/`](VMs/) | Single/multi Linux & Windows VMs, Azure Linux, DB/Linux benchmarks |
| [`AKS/`](AKS/) | AKS clusters (`aks-1`, `aks-2`, deploy / bill-run variants) |
| [`AVD/`](AVD/) | Azure Virtual Desktop test stacks |
| [`templates/`](templates/) | Starter patterns (not always turnkey) |
| [`testing/`](testing/) | Experiments (storage, maps, modules) |

Shared VM / AKS helper scripts live under [`../scripts/azure/`](../scripts/azure/), not under the stub `VMs/scripts` or `AKS/scripts` folders.

## Prerequisites

- Terraform installed
- Azure subscription + service principal (or equivalent) with rights to create the targeted resources
- [AzureRM provider docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

## Authentication

Prefer Terraform AzureRM environment variables (portable across tenants/subscriptions) over hard-coding credentials.

Source a local secrets file from your PowerShell profile:

```powershell
. '<drive>:\.hideme\somesecretstuff.ps1'
```

Then set:

```powershell
$env:ARM_TENANT_ID       = "$TFM_TenantID"
$env:ARM_SUBSCRIPTION_ID = "$TFM_SubID"
$env:ARM_CLIENT_ID       = "$TFM_AppID"
$env:ARM_CLIENT_SECRET   = "$TFM_AppSecret"
```

Backend helpers (optional): [`../scripts/create_azurerm_bkend.ps1`](../scripts/create_azurerm_bkend.ps1).

## Typical workflow

```bash
cd azure/VMs/linuxvm_1   # or CoreInfra/vnets, AKS/aks-1, …
# edit *.tfvars as needed
terraform init
terraform plan
terraform apply
```

Repo-wide apply shortcuts and conventions: [parent README](../README.md).

## Docs

- [Terraform on Azure](https://docs.microsoft.com/en-us/azure/developer/terraform/)
- [HashiCorp Learn — Azure](https://learn.hashicorp.com/collections/terraform/azure-get-started)
- [AzureRM Registry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

## Author

**Karl Vietmeier**

## License

Apache 2.0 — see [LICENSE.md](../LICENSE.md).
