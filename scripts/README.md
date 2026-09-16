# scripts/ — shared Terraform / lab utilities
#
# Canonical layout for standardized multi-cloud builds:
#
# ```text
# scripts/
# ├── cloud-init/     # Universal VM bootstrap (AWS/Azure/GCP) — START HERE for Linux labs
# ├── gcp/            # GCP-only helpers (sysprep, listing, legacy cloud-init copies)
# ├── azure/
# │   ├── vms/        # Azure VM cloud-init variants, bench assets
# │   └── aks/        # AKS / Arc helpers
# ├── aws/            # AWS-only helpers (placeholder; cloud-init is under cloud-init/)
# ├── InstallUpgradeTerraForm.ps1
# ├── create_azurerm_bkend.ps1
# └── vast.*          # VAST cluster helpers
# ```
#
# **Do not** keep new scripts under `gcp/scripts`, `azure/VMs/scripts`, etc.
# Those paths now contain short README stubs pointing here.
#
# Default Linux lab user-data:
# `scripts/cloud-init/cloud-init-universal.yaml`
# (see `scripts/cloud-init/README.md`)
