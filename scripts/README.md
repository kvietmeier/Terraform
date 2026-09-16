# scripts/ — shared Terraform / lab utilities

Canonical layout for standardized multi-cloud builds:

```text
scripts/
├── cloud-init/     # Universal Linux lab bootstrap (AWS / Azure / GCP)
│                   # Start here: cloud-init-universal.yaml + lab_bootstrap.sh
├── windows/        # Generic Windows VM scripts (any cloud)
│                   # sysprep specialize, static IP for AD/DNS
├── gcp/            # GCP-only: gcloud listing, GCE AD metadata, SSH snippets
├── azure/
│   ├── vms/        # Azure VM cloud-init variants / bench assets
│   └── aks/        # AKS / Arc helpers
├── aws/            # AWS-only helpers (placeholder)
├── InstallUpgradeTerraForm.ps1
├── create_azurerm_bkend.ps1
└── vast.*          # VAST cluster helpers
```

**Do not** add new scripts under `gcp/scripts`, `azure/VMs/scripts`, or `azure/AKS/scripts` — those directories are stubs that point here.

| Need | Path |
|------|------|
| Linux lab user-data | `cloud-init/cloud-init-universal.yaml` |
| Windows specialize / sysprep | `windows/windows-sysprep-*.ps1` |
| GCP instance listing | `gcp/listinstances*.ps1` |
| Azure AKS helpers | `azure/aks/` |

Details: `cloud-init/README.md`
