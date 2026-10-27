# view_policy_schema/ — documented view-policy schema reference

Fully annotated **view policy schema** for the VAST Data Terraform provider,
plus compact examples. The provider docs and Swagger never laid this out in one
place — this folder is that reference.

Use it to see every policy field (with defaults and comments), then copy what
you need into a real stack (`createviews/`, `basic_cluster/`, etc.).

## What’s here

| File | Role |
|------|------|
| [`views.variables.tf`](views.variables.tf) | Typed `lab_view_policies_config` schema — `optional()` factory defaults for each attribute |
| [`documented_template.tfvars.example`](documented_template.tfvars.example) | Exhaustive, comment-rich field catalog (one policy with every knob explained) |
| [`views.auto.tfvars.example`](views.auto.tfvars.example) | Short NFS / SMB / S3 policy + matching view examples |
| [`views.main.tf`](views.main.tf) | Example resource wiring (`vastdata_view_policy`, `vastdata_view`, optional block host sketches) |

Auth: `TF_VAR_vast_host` / `TF_VAR_vast_username` / `TF_VAR_vast_password` (provider block is in `views.main.tf`).

## How to use it

1. **Learn the schema** — read `documented_template.tfvars.example` (sections: identity, path behavior, snapshots, NFS / S3 / SMB, audit).
2. **See minimal shapes** — `views.auto.tfvars.example` (`lab_nfs_policy`, `lab_smb_policy`, `lab_s3_policy` + views).
3. **Copy into a working stack** — don’t treat this folder as your day-2 apply path.

```bash
export TF_VAR_vast_host="192.168.1.100"
export TF_VAR_vast_username="admin"
export TF_VAR_vast_password="CHANGE_ME"
```

## Notes

- Variable name for policies is `lab_view_policies_config` (variables + both example tfvars).
- Block host / mapping examples in `views.main.tf` are secondary illustrations only; the documented catalog is the **view policy** schema.
- Placeholders only (`192.168.1.100`, `default` tenant, example paths).
