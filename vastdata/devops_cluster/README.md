# devops_cluster

Cloud bring-up → **baseline functional cluster OOB**. Bells/whistles later.

No AD / SMB in Stage 4. VOC always creates VIP pool `protocolsPool`; config looks
it up and binds NFS/S3 view policies to it (does not recreate pools).

## Layout

| Path | Purpose |
|------|---------|
| `install_configure.py` | vastcloud create → capture → ONLINE poll → `config/` apply → S3 key extract |
| `config/` | Terraform from [`basic_cluster/`](../basic_cluster/) **plus DNS** + `protocolsPool` bind |
| `secrets/` | Local PGP key + extracted S3 credentials (not committed) |
| `create.env.example` | Stage 1 env template for `--create-env` |

## Stage 4 config

Users/groups, NFS + S3 views/policies (on `protocolsPool`), and protocol DNS.
AD / extra VIP pools / SMB can be layered on later.

```bash
cp config/config1.auto.tfvars.example config/config1.auto.tfvars
# edit DNS domain / views / users as needed
# place PGP public key at secrets/s3_pgp_key.asc
```

`install_configure.py` sets `TF_VAR_vast_host` (VMS IP) and `TF_VAR_dns_vip`
(from VOC `dns_vip` output when present).

## Quick start

```bash
export VAST_USERNAME=admin
export VAST_PASSWORD='...'
python3 install_configure.py --create-env create.env
# or against an existing cluster:
python3 install_configure.py --skip-create --cluster <name> --provider gcp
```
