#!/bin/bash
###=============================================================================###
# render_cloud_init.sh
#   Rebuild cloud-init-universal.yaml from:
#     cloud-init-universal.yaml.tftpl + lab_bootstrap.sh
#
# Run after editing lab_bootstrap.sh so file()-based Terraform modules stay current.
# Prefer templatefile() in new modules (no render step required).
###=============================================================================###
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
TPL="${DIR}/cloud-init-universal.yaml.tftpl"
SRC="${DIR}/lab_bootstrap.sh"
OUT="${DIR}/cloud-init-universal.yaml"

if [[ ! -f "$TPL" || ! -f "$SRC" ]]; then
    echo "Missing template or lab_bootstrap.sh in $DIR" >&2
    exit 1
fi

python3 - "$TPL" "$SRC" "$OUT" <<'PY'
import base64, pathlib, sys
tpl_path, src_path, out_path = map(pathlib.Path, sys.argv[1:4])
b64 = base64.b64encode(src_path.read_bytes()).decode("ascii")
text = tpl_path.read_text()
if "${bootstrap_b64}" not in text:
    raise SystemExit("template missing ${bootstrap_b64} placeholder")
out_path.write_text(text.replace("${bootstrap_b64}", b64))
print(f"Wrote {out_path} ({out_path.stat().st_size} bytes)")
PY

head -1 "$OUT" | grep -q '#cloud-config'
echo "OK: commit cloud-init-universal.yaml with lab_bootstrap.sh."
