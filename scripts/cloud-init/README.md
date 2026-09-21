# Cloud-init — multi-cloud lab bootstrap

Standardized Linux VM user-data for AWS, Azure, and GCP (Debian/Ubuntu and RHEL-family).

- **YAML** installs the standard devops toolset (`packages:`)
- **`lab_bootstrap.sh`** does everything that branches by OS/cloud (chrony, labuser, optional bench compiles)

## Files

| File | Role |
|------|------|
| `lab_bootstrap.sh` | Bootstrap logic — **source of truth** |
| `cloud-init-universal.yaml.tftpl` | Template with `${bootstrap_b64}` placeholder |
| `cloud-init-universal.yaml` | Ready-to-use file (script already embedded) |
| `render_cloud_init.sh` | Builds `.yaml` from `.tftpl` + `lab_bootstrap.sh` |
| `deprecated/` | Old per-cloud copies — do not use |

`.yaml` and `.tftpl` are **not** two designs. The template builds the yaml.

## Workflow A — existing stacks (default)

Most modules use `file(var.cloudinit_configfile)`. Use the **`.yaml`**.

### 1. Point Terraform at the rendered file

```hcl
cloudinit_configfile = "../../../scripts/cloud-init/cloud-init-universal.yaml"
```

### 2. Apply as usual

```bash
terraform apply
```

VM boots → cloud-init installs packages → runs `/tmp/lab_bootstrap.sh`.

### 3. When you change bootstrap behavior

```bash
# edit the script
vim scripts/cloud-init/lab_bootstrap.sh

# rebuild the .yaml so file() stacks pick up the change
cd scripts/cloud-init && ./render_cloud_init.sh

# commit both
git add lab_bootstrap.sh cloud-init-universal.yaml
git commit -m "Update lab bootstrap"
```

Ignore `.tftpl` for this workflow.

## Workflow B — new modules (optional)

Use `templatefile` so Terraform embeds `lab_bootstrap.sh` at plan/apply. No render step.

### 1. Wire the template

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

Attach `data.cloudinit_config.lab.rendered` as user-data / metadata.

### 2. When you change bootstrap behavior

```bash
vim scripts/cloud-init/lab_bootstrap.sh
git add lab_bootstrap.sh
git commit -m "Update lab bootstrap"
# no ./render_cloud_init.sh — Terraform reads the script directly
```

## What gets installed

| Layer | What | Where |
|-------|------|--------|
| Standard devops toolset | vim, git, curl, python3, tmux, tree, jq, htop, sysstat, … | YAML `packages:` |
| Bench tools (optional) | fio, iperf, dool, sockperf, elbencho | `lab_bootstrap.sh` when `INSTALL_BENCH_TOOLS=true` |
| Personal tools (optional) | `sys-perf-tools`, `system-tools` | `/home/labuser/tools/` when `CLONE_TOOLS_REPOS=true` |

## Environment knobs

Set on the guest before bootstrap (or wrap `runcmd`):

| Variable | Default | Meaning |
|----------|---------|---------|
| `INSTALL_BENCH_TOOLS` | `true` | Compile fio / iperf / dool / sockperf / elbencho |
| `CLONE_LAB_SCRIPTS` | `true` | Clone helper scripts into `/home/labuser` |
| `CLONE_TOOLS_REPOS` | `true` | Clone `sys-perf-tools` + `system-tools` into `/home/labuser/tools` |

## Quick decision

```text
Using file(cloudinit_configfile)?  →  Workflow A  (.yaml + render after script edits)
Wiring a new module?               →  Workflow B  (.tftpl + templatefile, no render)
```
