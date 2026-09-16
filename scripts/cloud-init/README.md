# Cloud-init — standardized multi-cloud lab bootstrap
#
# For IT / standardized Terraform builds. One script, one YAML template,
# AWS / Azure / GCP (Debian/Ubuntu and RHEL-family).
#
# ## Layout (repo-wide scripts/)
#
# ```text
# scripts/
#   cloud-init/     # THIS DIR — shared universal Linux bootstrap
#   windows/        # Generic Windows sysprep / static IP
#   gcp/            # GCP-only (gcloud, GCE AD metadata)
#   azure/          # Azure-specific (vms/, aks/)
#   aws/            # AWS-specific
#   *.ps1 / vast.*  # cross-cutting utilities at scripts/ root
# ```
#
# ## Files here
#
# | File | Role |
# |------|------|
# | `lab_bootstrap.sh` | **Source of truth** — OS/cloud branching, chrony, labuser, optional bench compiles |
# | `cloud-init-universal.yaml.tftpl` | Thin cloud-config; embeds script as base64 |
# | `render_cloud_init.sh` | Regenerates committed `cloud-init-universal.yaml` |
# | `cloud-init-universal.yaml` | Rendered artifact for modules using `file()` |
# | `deprecated/` | Old per-cloud embeds — do not use for new work |
#
# ## Terraform usage
#
# ### Preferred (new modules)
#
# ```hcl
# locals {
#   ci = "${path.module}/../../../scripts/cloud-init"
# }
#
# data "cloudinit_config" "lab" {
#   gzip          = false
#   base64_encode = false
#   part {
#     content_type = "text/cloud-config"
#     content = templatefile("${local.ci}/cloud-init-universal.yaml.tftpl", {
#       bootstrap_b64 = base64encode(file("${local.ci}/lab_bootstrap.sh"))
#     })
#     filename = "lab.yaml"
#   }
# }
# ```
#
# ### Compatible (`file(var.cloudinit_configfile)`)
#
# ```hcl
# cloudinit_configfile = "../../../scripts/cloud-init/cloud-init-universal.yaml"
# ```
#
# After editing `lab_bootstrap.sh`:
#
# ```bash
# cd scripts/cloud-init && ./render_cloud_init.sh
# ```
#
# ## Knobs
#
# | Variable | Default | Meaning |
# |----------|---------|---------|
# | `INSTALL_BENCH_TOOLS` | `true` | Compile fio, iperf, dool, sockperf, elbencho |
# | `CLONE_LAB_SCRIPTS` | `true` | Clone helper scripts into `/home/labuser` |
#
# Comfort packages (vim, git, python3, tmux, …) always install via YAML `packages:`.
