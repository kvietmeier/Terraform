#!/usr/bin/env bash
set -euo pipefail

CLUSTERS_FILE="${1:-clusters.txt}"

if [ ! -f "$CLUSTERS_FILE" ]; then
  echo "ERROR: clusters file not found: $CLUSTERS_FILE"
  exit 1
fi

terraform init

while read -r CLUSTER; do
  # Skip empty lines and comments
  [[ -z "$CLUSTER" ]] && continue
  [[ "$CLUSTER" =~ ^# ]] && continue

  echo
  echo "============================================================"
  echo "Applying Terraform to VAST cluster: $CLUSTER"
  echo "============================================================"

  SAFE_NAME="$(echo "$CLUSTER" | sed 's/[^a-zA-Z0-9_-]/_/g')"
  STATE_FILE="terraform-${SAFE_NAME}.tfstate"

  terraform plan \
    -state="$STATE_FILE" \
    -var="vast_host=$CLUSTER" \
    -out="plan-${SAFE_NAME}.tfplan"

  terraform apply \
    -state="$STATE_FILE" \
    "plan-${SAFE_NAME}.tfplan"

done < "$CLUSTERS_FILE"
