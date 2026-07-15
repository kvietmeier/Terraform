#!/usr/bin/env bash
###===================================================================================###
# FILE: cluster_setup.sh
# PURPOSE: Loops through cluster_list.txt, updates symlinks, syncs tfvars, applies TF.
###===================================================================================###

INVENTORY_FILE="cluster_list.txt"
BASE_CONFIG_DIR="$(pwd)/base-config"

# Verification checkpoint
if [ ! -f "$INVENTORY_FILE" ]; then
    echo "[-] Error: Cluster tracking file not found at: $INVENTORY_FILE"
    exit 1
fi

echo "[+] Starting VAST Multi-Cluster Sync & Deployment..."
echo "[+] Processing inventory from $INVENTORY_FILE"

success_count=0
fail_count=0
failed_clusters=()

while IFS= read -r line || [ -n "$line" ]; do
    line=$(echo "$line" | xargs)

    # Skip empty lines and comment headers (#)
    if [ -z "$line" ] || [[ "$line" =~ ^# ]]; then
        continue
    fi

    # Parse cluster_name, ip_address
    IFS=',' read -r cluster_name ip_address <<< "$line"
    cluster_name=$(echo "$cluster_name" | xargs)
    ip_address=$(echo "$ip_address" | xargs)

    WORKSPACE_DIR="work_${cluster_name}"

    echo "======================================================================"
    echo "[+] ORCHESTRATING WORKSPACE: $WORKSPACE_DIR ($ip_address)"
    echo "======================================================================"

    # 1. Generate the workspace folder if it's missing
    if [ ! -d "$WORKSPACE_DIR" ]; then
        echo "[+] Generating missing workspace structure: $WORKSPACE_DIR"
        mkdir -p "$WORKSPACE_DIR"
    fi

    # 2. Maintain / Create Symlinks to base-config exactly like your tree schema
    for tf_file in locals.tf main.tf outputs.tf provider.tf users.tf variables.tf; do
        if [ ! -L "$WORKSPACE_DIR/$tf_file" ]; then
            echo "    -> Linking $tf_file"
            ln -s "$BASE_CONFIG_DIR/$tf_file" "$WORKSPACE_DIR/$tf_file"
        fi
    done

    # 3. CRITICAL SYNC: Overwrite the local tfvars file with your new 10-user master list
    if [ -f "$BASE_CONFIG_DIR/terraform.tfvars" ]; then
        echo "    -> Syncing master terraform.tfvars into workspace..."
        cp "$BASE_CONFIG_DIR/terraform.tfvars" "$WORKSPACE_DIR/terraform.tfvars"
    fi

    # 4. Check for safety block
    if [ ! -f "$WORKSPACE_DIR/terraform.tfvars" ]; then
        echo "[-] FAILURE: Missing terraform.tfvars in $WORKSPACE_DIR"
        ((fail_count++))
        failed_clusters+=("$cluster_name ($ip_address) - Missing terraform.tfvars")
        continue
    fi

    # 5. Jump into the target workspace directory
    pushd "$WORKSPACE_DIR" > /dev/null || continue

    # 6. Initialize the unique workspace
    terraform init -upgrade > /dev/null
    
    # --- Emergency Lab Sync Hook: Purge old conflicting local group entries via API ---
    echo "    [!] Running API pre-clearance on target cluster..."
    curl -k -s -X DELETE -u "admin:123456" "https://$ip_address/api/latest/groups/1/" > /dev/null
    curl -k -s -X DELETE -u "admin:123456" "https://$ip_address/api/latest/groups/2/" > /dev/null
    curl -k -s -X DELETE -u "admin:123456" "https://$ip_address/api/latest/groups/3/" > /dev/null
    
    # Clears out historical view conflicts 3 through 11
    for view_id in {3..11}; do
        curl -k -s -X DELETE -u "admin:123456" "https://$ip_address/api/latest/views/$view_id/" > /dev/null
    done
    
    # 7. Execute the plan
    terraform apply \
      -var="vast_host=$ip_address" \
      -auto-approve

    if [ $? -eq 0 ]; then
        echo "[+] SUCCESS: State tracking metrics synced on $cluster_name."
        ((success_count++))
    else
        echo "[-] FAILURE: Terraform execution sequence faulted on $cluster_name."
        ((fail_count++))
        failed_clusters+=("$cluster_name ($ip_address)")
    fi

    # 8. Step back to root cleanly
    popd > /dev/null || continue
    echo ""

done < "$INVENTORY_FILE"

#=====================================================================================
# FINAL SUMMARY RUN REPORT
#=====================================================================================
echo "======================================================================"
echo " LAB DEPLOYMENT LIFECYCLE SUMMARY REPORT"
echo "======================================================================"
echo "[+] Successfully provisioned: $success_count cluster(s)."

if [ $fail_count -gt 0 ]; then
    echo "[-] Critical Errors: $fail_count cluster(s) failed deployment."
    echo "[-] Failed Target Inventory List:"
    for bad_node in "${failed_clusters[@]}"; do
        echo "    -> $bad_node"
    done
    exit 1
else
    echo "[+] Global Deployment Status: ALL SYNCED AND READY FOR LAB USE."
    exit 0
fi