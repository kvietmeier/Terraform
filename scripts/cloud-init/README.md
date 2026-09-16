# Cloud-init — multi-cloud lab bootstrap

Standardized Linux VM user-data for AWS, Azure, and GCP (Debian/Ubuntu and RHEL-family).

YAML installs portable packages. All OS/cloud branching lives in `lab_bootstrap.sh`.

## Files

| File | Role |
|------|------|
| `lab_bootstrap.sh` | Source of truth — chrony, labuser, optional bench compiles |
| `cloud-init-universal.yaml.tftpl` | Thin cloud-config; embeds script as base64 |
| `render_cloud_init.sh` | Regenerates committed `cloud-init-universal.yaml` |
| `cloud-init-universal.yaml` | Rendered artifact for modules using `file()` |
| `deprecated/` | Old per-cloud embeds — do not use for new work |

## Terraform usage

### Preferred (new modules)

```hcl
locals {
  ci = "${path.module}/../../../scripts/cloud-init"
}

data "cloudinit_config" "lab" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content = templatefile("${local.ci}/cloud-init-universal.yaml.tftpl", {
      bootstrap_b64 = base64encode(file("${local.ci}/lab_bootstrap.sh"))
    })
    filename = "lab.yaml"
  }
}
```

### Compatible (`file(var.cloudinit_configfile)`)

```hcl
cloudinit_configfile = "../../../scripts/cloud-init/cloud-init-universal.yaml"
```

After editing `lab_bootstrap.sh`:

```bash
cd scripts/cloud-init && ./render_cloud_init.sh
```

## Environment knobs

| Variable | Default | Meaning |
|----------|---------|---------|
| `INSTALL_BENCH_TOOLS` | `true` | Compile fio, iperf, dool, sockperf, elbencho |
| `CLONE_LAB_SCRIPTS` | `true` | Clone helper scripts into `/home/labuser` |

Comfort packages (vim, git, python3, tmux, …) always install via the YAML `packages:` list.
