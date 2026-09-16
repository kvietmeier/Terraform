# Cloud-init — multi-cloud lab bootstrap

Standardized Linux VM user-data for AWS, Azure, and GCP (Debian/Ubuntu and RHEL-family).

YAML installs portable packages. All OS/cloud branching lives in `lab_bootstrap.sh`.

## `.yaml` vs `.tftpl` — which to use?

These are **not** two different cloud-init designs. The `.tftpl` is how we *build* the `.yaml`.

| File | What it is |
|------|------------|
| `lab_bootstrap.sh` | Real bootstrap logic (**source of truth**) |
| `cloud-init-universal.yaml.tftpl` | Template with placeholder `${bootstrap_b64}` for the script |
| `cloud-init-universal.yaml` | Ready-to-use copy — script already baked in as base64 |
| `render_cloud_init.sh` | Fills the template → writes the committed `.yaml` |
| `deprecated/` | Old per-cloud embeds — do not use for new work |

**Rule of thumb:** use the **`.yaml`** unless you are wiring a new module with `templatefile`. You can ignore `.tftpl` until then.

### Why both exist

- Older modules only know `file("something.yaml")` → need the rendered `.yaml`
- Embedding the script as base64 avoids the old bug where indented YAML corrupted the shell script
- `.tftpl` is the clean long-term path; `.yaml` is the compatibility artifact

## Day-to-day / existing stacks

Use the rendered file:

```hcl
cloudinit_configfile = "../../../scripts/cloud-init/cloud-init-universal.yaml"
```

### After editing `lab_bootstrap.sh`

If stacks use the **`.yaml`**, re-render and commit it:

```bash
cd scripts/cloud-init && ./render_cloud_init.sh
```

## New modules (optional)

Terraform fills the placeholder at plan/apply — no render step required:

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

If stacks use **`.tftpl` + `templatefile`**, just commit `lab_bootstrap.sh` — no `render_cloud_init.sh` needed.

## Environment knobs

| Variable | Default | Meaning |
|----------|---------|---------|
| `INSTALL_BENCH_TOOLS` | `true` | Compile fio, iperf, dool, sockperf, elbencho |
| `CLONE_LAB_SCRIPTS` | `true` | Clone helper scripts into `/home/labuser` |

Comfort packages (vim, git, python3, tmux, …) always install via the YAML `packages:` list.
