# scripts/

Shared helpers for multi-cloud Terraform lab builds.

## Layout

```text
scripts/
├── cloud-init/     # Universal Linux lab bootstrap (AWS / Azure / GCP)
├── windows/        # Generic Windows VM scripts (any cloud)
├── gcp/            # GCP-only (gcloud listing, GCE AD metadata, SSH snippets)
├── azure/
│   ├── vms/        # Azure VM cloud-init variants / bench assets
│   └── aks/        # AKS / Arc helpers
├── aws/            # AWS-only helpers
├── InstallUpgradeTerraForm.ps1
├── create_azurerm_bkend.ps1
└── vast.*          # VAST cluster helpers
```

Do **not** add new scripts under `gcp/scripts`, `azure/VMs/scripts`, or `azure/AKS/scripts` — those directories are stubs that point here.

## Quick links

| Need | Path |
|------|------|
| Linux lab user-data | [`cloud-init/`](cloud-init/) — use **`cloud-init-universal.yaml`** day-to-day |
| Windows specialize / sysprep | [`windows/`](windows/) |
| GCP instance listing | [`gcp/`](gcp/) |
| Azure AKS helpers | [`azure/aks/`](azure/aks/) |

Cloud-init has both a `.yaml` (ready to `file()`) and a `.tftpl` (for `templatefile`).  
See [`cloud-init/README.md`](cloud-init/README.md) — **rule of thumb: use the `.yaml`**.
