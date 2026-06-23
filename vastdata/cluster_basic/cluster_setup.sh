#!/usr/bin/env bash

set -euo pipefail

# --- DYNAMIC REPO ENVIRONMENT PATHING ---
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="${ROOT_DIR}/base-config"
HOSTS_FILE="${ROOT_DIR}/cluster_list.txt"

# --- GLOBAL STORAGE DETAILS ---
BACKEND_BUCKET="clouddev-itdesk124-tfstate"
BASE_PREFIX="terraform/state/lab_clusters" 

# --- ANSI TERMINAL COLORS ---
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' 

# ==============================================================================
# ENGINE HELPER FUNCTIONS
# ==============================================================================

log_msg() { echo -e "${GREEN}[LAB ENGINE] $(date +'%Y-%m-%d %H:%M:%S') - $1${NC}"; }
log_warn() { echo -e "${YELLOW}[LAB WARN]   $(date +'%Y-%m-%d %H:%M:%S') - $1${NC}"; }
log_err() { echo -e "${RED}[LAB ERROR]  $(date +'%Y-%m-%d %H:%M:%S') - $1${NC}" >&2; }

print_usage() {
    echo "Usage: $0 [action]"
    echo "Actions:"
    echo "  --apply    Initialize, update, or skip existing VAST clusters safely."
    echo "  --destroy  Tear down all configured infrastructure for clusters listed in the inventory."
    exit 1
}

# Ensure baseline operational assets exist before running
validate_environment() {
    if [ ! -f "$HOSTS_FILE" ]; then
        log_err "CRITICAL: Inventory tracking file not found at $HOSTS_FILE"
        exit 1
    fi
    if [ ! -d "$TEMPLATE_DIR" ]; then
        log_err "CRITICAL: Base templates directory not found at $TEMPLATE_DIR"
        exit 1
    fi
}

# Build out the symlinked workspace execution tracking paths
prepare_workspace() {
    local cluster_name=$1
    local ip_address=$2
    local work_dir="${ROOT_DIR}/work_${cluster_name}"

    mkdir -p "$work_dir"
    
    # Symlink all baseline *.tf modules smoothly
    for master_file in "${TEMPLATE_DIR}"/*.tf; do
        if [ -f "$master_file" ]; then
            local filename=$(basename "$master_file")
            ln -sf "$master_file" "${work_dir}/${filename}"
        fi
    done

    # Recover the global template payload attributes if present
    if [ -f "${TEMPLATE_DIR}/terraform.tfvars" ]; then
        cp "${TEMPLATE_DIR}/terraform.tfvars" "${work_dir}/cluster_payload.auto.tfvars"
    else
        log_warn "No static terraform.tfvars dictionary found in base-config/"
    fi

    # Inject the runtime target connection configurations over the workspace payload
    cat <<EOF > "${work_dir}/terraform.tfvars"
vast_username = "admin"
vast_password = "123456"
vast_host     = "${ip_address}"
vast_port     = 443
EOF

    echo "$work_dir"
}

# ==============================================================================
# MAIN CORE LIFECYCLE PIPELINE
# ==============================================================================

run_lifecycle() {
    local action=$1
    validate_environment

    # Clean out any loose workspace configurations from aborted runs
    rm -rf "${ROOT_DIR}"/work_*/

    while IFS= read -r line || [ -n "$line" ]; do
        line=$(echo "$line" | xargs)

        # Skip empty strings and shell comment headings
        if [ -z "$line" ] || [[ "$line" =~ ^# ]]; then
            continue
        fi

        local cluster_name=$(echo "$line" | cut -d',' -f1 | xargs)
        local ip_address=$(echo "$line" | cut -d',' -f2 | xargs)

        log_msg "=========================================================="
        log_msg "Starting Target Execution: ${cluster_name} (${ip_address})"
        log_msg "=========================================================="

        # Call our workspace setup function
        local active_workspace=$(prepare_workspace "$cluster_name" "$ip_address")
        cd "$active_workspace"

        local cluster_prefix="${BASE_PREFIX}/${cluster_name}"
        log_msg "Connecting backend infrastructure to path: ${cluster_prefix}"

        # Initialize tracking maps safely
        terraform init -input=false -reconfigure \
            -backend-config="bucket=${BACKEND_BUCKET}" \
            -backend-config="prefix=${cluster_prefix}"

        # Evaluate and route lifecycle action execution maps
        if [ "$action" == "apply" ]; then
            log_msg "Synchronizing configuration updates..."
            if terraform apply -input=false -auto-approve -var-file="terraform.tfvars"; then
                log_msg "SUCCESS: Operations application stabilized for ${cluster_name}."
            else
                log_err "FAILURE: Lifecycle sync broke on cluster target: ${cluster_name}."
                continue
            fi
        elif [ "$action" == "destroy" ]; then
            log_warn "WARNING: Initiating complete infrastructure destruction sequence..."
            if terraform destroy -input=false -auto-approve -var-file="terraform.tfvars"; then
                log_msg "SUCCESS: Clean teardown completed for ${cluster_name}."
            else
                log_err "FAILURE: Destruction pipeline execution failed on target: ${cluster_name}."
                continue
            fi
        fi

    done < "$HOSTS_FILE"
}

# ==============================================================================
# ENTRYPOINT EXECUTION PARSER
# ==============================================================================

if [ $# -ne 1 ]; then
    print_usage
fi

case "$1" in
    --apply)
        run_lifecycle "apply"
        ;;
    --destroy)
        run_lifecycle "destroy"
        ;;
    *)
        print_usage
        ;;
esac

log_msg "Pipeline runtime tracking routine terminated successfully."