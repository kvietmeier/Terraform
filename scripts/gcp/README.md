# scripts/gcp/ — GCP-only helpers

| File | Purpose |
|------|---------|
| `listinstances.ps1` / `listinstances-table.ps1` | `gcloud` private IP / DNS tables |
| `VM_SSH_gcp_config.txt` | SSH config snippets for GCP private DNS |
| `createDCscript.ps1` / `dc-startup.ps1` / `setup_dc_server22.ps1` | AD DC on GCE (metadata / `gce_base.psm1`) |

**Not here:** generic Windows sysprep / static IP → `../windows/`  
**Linux bootstrap:** `../cloud-init/cloud-init-universal.yaml`
