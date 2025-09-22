#!/usr/bin/env bash
# ==============================================================================
# decrypt_vast_keys.sh
#
# Automatically extracts and decrypts all VAST user keys from Terraform state.
# Saves access key and decrypted secret to ../secrets/<username>.txt
# ==============================================================================

set -euo pipefail  # Exit on errors, unset variables, and pipe failures

# -----------------------------
# Paths
# -----------------------------
TF_ROOT="/home/karlv/Terraform/vastdata/cluster_config"            # Terraform state directory
PRIVATE_KEY_FILE="/home/karlv/Terraform/vastdata/secrets/s3_pgp_private.asc"  # PGP private key
OUTPUT_DIR="/home/karlv/Terraform/vastdata/secrets"                # Directory to save decrypted secrets

# -----------------------------
# Pre-flight checks
# -----------------------------
if [ ! -d "$TF_ROOT" ]; then
    echo "Error: Terraform state directory not found: $TF_ROOT"
    exit 1
fi
if [ ! -f "$PRIVATE_KEY_FILE" ]; then
    echo "Error: Private key file not found: $PRIVATE_KEY_FILE"
    exit 1
fi

# Create output directory if it does not exist
mkdir -p "$OUTPUT_DIR"

# -----------------------------
# Import private key if needed
# -----------------------------
# Only import if the key "vast-s3@example.com" is not already in GPG
if ! gpg --list-secret-keys | grep -q "vast-s3@example.com"; then
    echo "Importing private key..."
    gpg --import "$PRIVATE_KEY_FILE"
fi

# -----------------------------
# Change to Terraform state directory
# -----------------------------
cd "$TF_ROOT"

# -----------------------------
# Process each user key
# -----------------------------
# Find all Terraform resources that match 'vastdata_user_key.s3keys[...]'
terraform state list \
  | grep '^vastdata_user_key\.s3keys\[' \
  | while read -r key; do

      # Extract username from the resource name, e.g., s3user1 or dbuser1
      username=$(echo "$key" | sed -E 's/.*\["([^"]+)"\]$/\1/')

      echo "Processing user: $username"

      # -----------------------------
      # Extract access key
      # -----------------------------
      # Pull the access_key field from Terraform state
      ACCESS_KEY=$(terraform state show "$key" | awk '/access_key/ {gsub(/"/,"",$3); print $3}')

      # -----------------------------
      # Decrypt secret key
      # -----------------------------
      # Extract the PGP block and decrypt it directly
      SECRET=$(terraform state show "$key" \
        | awk '/-----BEGIN PGP MESSAGE-----/{flag=1} flag; /-----END PGP MESSAGE-----/{flag=0}' \
        | sed 's/^[ \t]*//' \
        | gpg --decrypt 2>/dev/null \
        | tr -d '\n' \
        | awk '{print $NF}')

      # -----------------------------
      # Validate extraction
      # -----------------------------
      if [ -z "$ACCESS_KEY" ] || [ -z "$SECRET" ]; then
          echo "  Error: Failed to extract or decrypt key for $username"
          continue
      fi

      # -----------------------------
      # Save combined access key and secret
      # -----------------------------
      # Write both access key and decrypted secret to a single file
      {
        echo "Access Key: $ACCESS_KEY"
        echo "Secret Key: $SECRET"
      } > "$OUTPUT_DIR/${username}.txt"

      # -----------------------------
      # Output status
      # -----------------------------
      echo "  Access Key and Secret saved to $OUTPUT_DIR/${username}.txt"
      echo "----------------------------------------"

  done

echo "All VAST user keys processed successfully."
