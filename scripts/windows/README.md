# scripts/windows/

Cloud-agnostic Windows helpers for Terraform `sysprep-specialize` / startup scripts.

| File | Purpose |
|------|---------|
| `windows-sysprep-config.ps1` | Specialize: users, password, baseline setup |
| `windows-sysprep-test.ps1` | Lab/test variant of the above |
| `ConfigureStaticIP.ps1` | Set NIC to static IP (AD/DNS scenarios) |

## Usage

GCP stacks set:

```hcl
windows-sysprep-script = "../../../scripts/windows/windows-sysprep-config.ps1"
```
