#!/bin/bash
################################################################################
# Script Name : tf-apply-destroy-with-countdown.sh
#
# Description :
#   Applies and destroys Terraform infrastructure for selected clusters.
#   Prints countdown status every 15 minutes during the delay window using a
#   background process that writes to stdout.
#
# Parameters :
#   $1 [Required]  - Delay in hours between apply and destroy
#
# Usage :
#   ./tf-apply-destroy-with-countdown.sh 3
#
# Logging :
#   - Logs output in each cluster directory as:
#       tf-apply-YYYYMMDD-HHMMSS.log
#       tf-destroy-YYYYMMDD-HHMMSS.log
################################################################################

set -euo pipefail

# Validate input
if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <delay_hours>"
  exit 1
fi

DELAY_HOURS="$1"
DELAY_SECONDS=$(echo "$DELAY_HOURS * 3600" | bc)
INTERVAL=900  # 15 minutes

BASE_PATH="$(pwd)"

# Get cluster directories
echo "Available clusters:"
CLUSTERS=()
while IFS= read -r -d '' dir; do
  cname=$(basename "$dir")
  echo "- $cname"
  CLUSTERS+=("$cname")
done < <(find "$BASE_PATH" -maxdepth 1 -type d -name "cluster*" -print0)

read -p "Enter comma-separated cluster names to run (e.g. cluster01,cluster03): " selection
IFS=',' read -ra SELECTED <<< "$selection"

VALID_CLUSTERS=()
for cluster in "${SELECTED[@]}"; do
  cluster=$(echo "$cluster" | xargs)
  if [[ -d "$BASE_PATH/$cluster" ]]; then
    VALID_CLUSTERS+=("$cluster")
  else
    echo "Skipping $cluster (not found)"
  fi
done

if [[ ${#VALID_CLUSTERS[@]} -eq 0 ]]; then
  echo "No valid clusters selected. Exiting."
  exit 1
fi

# Clean up old logs
for cluster in "${VALID_CLUSTERS[@]}"; do
  cluster_path="$BASE_PATH/$cluster"
  echo "Removing old logs from $cluster..."
  find "$cluster_path" -maxdepth 1 -type f \( -name "tf-apply-*.log" -o -name "tf-destroy-*.log" \) -exec rm -f {} +
done

# Run terraform apply
for cluster in "${VALID_CLUSTERS[@]}"; do
  cluster_path="$BASE_PATH/$cluster"
  var_file=$(find "$cluster_path" -maxdepth 1 -name "*.tfvars" | head -n 1)

  if [[ -z "$var_file" ]]; then
    echo "No .tfvars file found in $cluster. Skipping apply."
    continue
  fi

  timestamp=$(date +"%Y%m%d-%H%M%S")
  log_apply="$cluster_path/tf-apply-$timestamp.log"

  echo
  echo "===== [$cluster] Running terraform apply ====="
  pushd "$cluster_path" > /dev/null
  terraform apply --auto-approve -var-file="$var_file" 2>&1 | tee "$log_apply"
  status=${PIPESTATUS[0]}
  popd > /dev/null

  if [[ $status -ne 0 ]]; then
    echo "terraform apply failed in $cluster. Exiting."
    exit 1
  fi
done

# Countdown background function
countdown() {
  local total="$1"
  local interval="$2"
  local remaining="$total"

  while (( remaining > 0 )); do
    now=$(date +"%H:%M:%S")
    mins=$(( remaining / 60 ))
    echo "[$now] Countdown: $mins minute(s) remaining..."
    sleep $(( interval < remaining ? interval : remaining ))
    remaining=$(( remaining - interval ))
  done
  echo "[$(date +"%H:%M:%S")] Countdown complete."
}

# Start countdown in background
countdown "$DELAY_SECONDS" "$INTERVAL" &
TIMER_PID=$!

# Wait for delay period
wait "$TIMER_PID"

# Run terraform destroy
for cluster in "${VALID_CLUSTERS[@]}"; do
  cluster_path="$BASE_PATH/$cluster"
  var_file=$(find "$cluster_path" -maxdepth 1 -name "*.tfvars" | head -n 1)

  if [[ -z "$var_file" ]]; then
    echo "No .tfvars file found in $cluster. Skipping destroy."
    continue
  fi

  timestamp=$(date +"%Y%m%d-%H%M%S")
  log_destroy="$cluster_path/tf-destroy-$timestamp.log"

  echo
  echo "===== [$cluster] Running terraform destroy ====="
  pushd "$cluster_path" > /dev/null
  terraform destroy --auto-approve -var-file="$var_file" 2>&1 | tee "$log_destroy"
  popd > /dev/null
done

echo
echo "All operations complete."
