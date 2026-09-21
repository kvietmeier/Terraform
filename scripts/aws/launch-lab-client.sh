#!/usr/bin/env bash
###=============================================================================###
# launch-lab-client.sh — non-Terraform VoC lab client launch (us-west-2)
#
# Prefer a golden AMI (fast boot, no compile). Falls back to Canonical Ubuntu
# 24.04 + gzipped universal cloud-init when AMI_ID is unset.
#
# Examples:
#   # Golden AMI (once CreateImage is granted / AMI baked)
#   AMI_ID=ami-0abc... ./launch-lab-client.sh voc-client04
#
#   # Fresh Ubuntu + full cloud-init bootstrap (slow first boot)
#   ./launch-lab-client.sh voc-client04
#
#   # Dry-run (prints aws CLI only)
#   DRY_RUN=1 ./launch-lab-client.sh voc-client04
#
# Requires: aws CLI, AWS_PROFILE with RunInstances + CreateTags.
# CreateImage is NOT needed to launch — only to bake the golden AMI.
###=============================================================================###

set -euo pipefail

REGION="${AWS_REGION:-us-west-2}"
NAME="${1:?usage: $0 <Name-tag>}"
INSTANCE_TYPE="${INSTANCE_TYPE:-m6i.2xlarge}"
VOLUME_SIZE="${VOLUME_SIZE:-256}"
SUBNET_ID="${SUBNET_ID:-subnet-004098aa31ced3b4f}"
SG_ID="${SG_ID:-sg-030dad04c3ef5f05b}"
KEY_NAME="${KEY_NAME:-karlv-aws_cloudkey}"
AMI_ID="${AMI_ID:-}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLOUDINIT_YAML="${CLOUDINIT_YAML:-${SCRIPT_DIR}/../cloud-init/cloud-init-universal.yaml}"
DRY_RUN="${DRY_RUN:-0}"

# Unset Cursor sandbox proxies if present (breaks SSO federation)
unset HTTP_PROXY HTTPS_PROXY http_proxy https_proxy ALL_PROXY all_proxy \
      GIT_HTTP_PROXY GIT_HTTPS_PROXY SOCKS_PROXY SOCKS5_PROXY || true

UD_FILE=""
TAG_FILE=""
cleanup() {
  [[ -n "$UD_FILE" && -f "$UD_FILE" ]] && rm -f "$UD_FILE"
  [[ -n "$TAG_FILE" && -f "$TAG_FILE" ]] && rm -f "$TAG_FILE"
}
trap cleanup EXIT

resolve_ami() {
  if [[ -n "$AMI_ID" ]]; then
    echo "$AMI_ID"
    return
  fi
  aws ec2 describe-images --region "$REGION" \
    --owners 099720109477 \
    --filters \
      "Name=name,Values=ubuntu/images/hvm-ssd*/ubuntu-noble-24.04-amd64-server-*" \
      "Name=virtualization-type,Values=hvm" \
      "Name=state,Values=available" \
    --query 'sort_by(Images,&CreationDate)[-1].ImageId' \
    --output text
}

# Solutions lab tags (matches aws/ec2/tux_clients/clients.auto.tfvars)
TAG_FILE="$(mktemp)"
python3 - "$NAME" "$TAG_FILE" <<'PY'
import json, sys
name, path = sys.argv[1], sys.argv[2]
common = [
    {"Key": "Name", "Value": name},
    {"Key": "UsedBy", "Value": "solutions"},
    {"Key": "used_by", "Value": "solutions"},
    {"Key": "owned", "Value": "solutions"},
    {"Key": "longrun", "Value": "yes"},
    {"Key": "Project", "Value": "VoC"},
    {"Key": "Environment", "Value": "lab"},
    {"Key": "Cluster", "Value": "karlv-i8test-01"},
    {"Key": "Lifecycle", "Value": "demo"},
]
with open(path, "w") as f:
    json.dump([
        {"ResourceType": "instance", "Tags": common},
        {"ResourceType": "volume", "Tags": common},
    ], f)
PY

AMI="$(resolve_ami)"
USER_DATA_ARGS=()
if [[ -z "$AMI_ID" ]]; then
  if [[ ! -f "$CLOUDINIT_YAML" ]]; then
    echo "ERROR: cloud-init yaml not found: $CLOUDINIT_YAML" >&2
    exit 1
  fi
  UD_FILE="$(mktemp)"
  gzip -c -n "$CLOUDINIT_YAML" > "$UD_FILE"
  USER_DATA_ARGS=(--user-data "fileb://${UD_FILE}")
  echo "Using Ubuntu AMI ${AMI} + gzipped cloud-init ($(wc -c < "$UD_FILE" | tr -d ' ') bytes)"
else
  echo "Using golden AMI ${AMI} (no cloud-init user-data)"
fi

ARGS=(
  aws ec2 run-instances
  --region "$REGION"
  --image-id "$AMI"
  --instance-type "$INSTANCE_TYPE"
  --subnet-id "$SUBNET_ID"
  --security-group-ids "$SG_ID"
  --key-name "$KEY_NAME"
  --block-device-mappings "DeviceName=/dev/sda1,Ebs={VolumeSize=${VOLUME_SIZE},VolumeType=gp3,DeleteOnTermination=true}"
  --tag-specifications "file://${TAG_FILE}"
  --count 1
)
ARGS+=("${USER_DATA_ARGS[@]}")
[[ "$DRY_RUN" == "1" ]] && ARGS+=(--dry-run)

echo "Launching ${NAME} (${INSTANCE_TYPE}) in ${REGION}..."
if [[ "$DRY_RUN" == "1" ]]; then
  "${ARGS[@]}" || true
else
  OUT="$("${ARGS[@]}" --output json)"
  echo "$OUT" | python3 -c '
import json, sys
r = json.load(sys.stdin)["Instances"][0]
print(f"InstanceId={r[\"InstanceId\"]} PrivateIp={r.get(\"PrivateIpAddress\", \"pending\")}")
'
fi
