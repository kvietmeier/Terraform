# policies/ — S3 policy JSON examples

Copy/paste starting points for VAST S3 **user policies** (IAM-style JSON).
Stacks load a path via tfvars; you can also paste a document into the VMS or a
`vastdata_s3_policy` resource.

Use placeholders only. Replace bucket names, ARNs, and paths for your lab.

## How stacks use these

```hcl
# *.auto.tfvars.example in basic_cluster / complete_cluster_config / cluster_gcp
s3_allowall_policy_file = "../policies/s3Policy-VastAllowAll.json"
s3_allowall_policy_name = "s3_user_AllowAll"
```

Point `s3_allowall_policy_file` (or your own variable) at any file here, then
`file()` / `jsondecode()` in the module.

## Catalog

| File | Intent |
|------|--------|
| [`s3Policy-VastAllowAll.json`](s3Policy-VastAllowAll.json) | Canonical allow-all used by example stacks — **lab only** |
| [`example.s3Policy_AllowAll.json`](example.s3Policy_AllowAll.json) | Alternate wide-open `Action`/`Resource` `*` |
| [`s3Policy-VastAllowAll2.json`](s3Policy-VastAllowAll2.json) | `s3:*` on a single path-style resource string |
| [`s3Policy-VastAllowAll3.json`](s3Policy-VastAllowAll3.json) | Same idea with `arn:aws:s3:::…` resource form |
| [`s3Policy-Detailed.example.json`](s3Policy-Detailed.example.json) | Split list vs object actions on `DOC-EXAMPLE-BUCKET1` |
| [`s3Policy-DBAllowAllTabular.json`](s3Policy-DBAllowAllTabular.json) | Tabular API allow (`s3:Tabular*`) on all buckets |

## Notes

- VAST accepts S3 IAM-like JSON; resource strings may be path-style or
  `arn:aws:s3:::bucket[/key]` depending on the action and cluster version —
  prefer the form your VMS UI shows for a working policy.
- `DOC-EXAMPLE-BUCKET1`, `sparktesting/…`, and similar strings are **placeholders**.
- Allow-all / `*` policies are for throwaway labs, not production.

## Author

Karl Vietmeier — Apache 2.0
