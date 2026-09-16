# scripts/windows/ — generic Windows VM scripts

Cloud-agnostic helpers used as Terraform `sysprep-specialize` / startup scripts on any provider.

| File | Purpose |
|------|---------|
| `windows-sysprep-config.ps1` | Specialize: users, password, baseline setup |
| `windows-sysprep-test.ps1` | Lab/test variant of the above |
| `ConfigureStaticIP.ps1` | Set NIC to static IP (AD/DNS scenarios) |

GCP stacks currently reference these via `windows-sysprep-script = ".../scripts/windows/..."`.
