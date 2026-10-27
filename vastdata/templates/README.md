# templates/ — S3 policy JSON examples

Copy/paste starting points for VAST S3 **user policies** (IAM-style JSON).
These are **not** applied by Terraform on their own — stacks load a file path
via tfvars (see sibling [`../policies/`](../policies/)) or you paste the
document into the VMS / provider `vastdata_s3_policy` resource.

Use placeholders only. Replace bucket names, ARNs, and paths for your lab.

## `templates/` vs `policies/`

| Path | Role |
|------|------|
| **`templates/`** (this dir) | Teaching / variant catalog — allow-all, scoped bucket, tabular, detailed |
| **`../policies/`** | Canonical file referenced by example stacks (`s3_allowall_policy_file`) |

Example stacks point at the policies tree:

```hcl
# basic_cluster / complete_cluster_config / cluster_gcp *.auto.tfvars.example
s3_allowall_policy_file = "../policies/s3Policy-VastAllowAll.json"
s3_allowall_policy_name = "s3_user_AllowAll"
```

Wire a template the same way: copy or set `s3_allowall_policy_file` (or your
own variable) to the JSON path, then `file()` / `jsondecode()` in the module.

## Catalog

| File | Intent |
|------|--------|
| [`example.s3Policy_AllowAll.json`](example.s3Policy_AllowAll.json) | Wide-open `Action`/`Resource` `*` — **lab only** |
| [`s3Policy-VastAllowAll2.json`](s3Policy-VastAllowAll2.json) | `s3:*` on a single path-style resource string |
| [`s3Policy-VastAllowAll3.json`](s3Policy-VastAllowAll3.json) | Same idea with `arn:aws:s3:::…` resource form |
| [`s3Policy-Detailed.example.json`](s3Policy-Detailed.example.json) | Split list vs object actions on `DOC-EXAMPLE-BUCKET1` |
| [`example.s3Policy1.json`](example.s3Policy1.json) | Same pattern as detailed (list + CRUD on one bucket) |
| [`s3Policy-DBAllowAllTabular.json`](s3Policy-DBAllowAllTabular.json) | Tabular API allow (`s3:Tabular*`) on all buckets |

Sibling allow-all used by stacks: [`../policies/s3Policy-VastAllowAll.json`](../policies/s3Policy-VastAllowAll.json).

## Notes

- VAST accepts S3 IAM-like JSON; resource strings may be path-style or
  `arn:aws:s3:::bucket[/key]` depending on the action and cluster version —
  prefer the form your VMS UI shows for a working policy.
- `DOC-EXAMPLE-BUCKET1`, `sparktesting/…`, and similar strings are **placeholders**.
- Allow-all / `*` policies are for throwaway labs, not production.
- `vastdata.variables.tf` in this folder is a portable provider-vars stub, not a
  policy document.

## Author

Karl Vietmeier — Apache 2.0
