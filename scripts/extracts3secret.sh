#!/bin/bash
# ==============================================================================
# get_vast_secret.sh
#
# Usage:
#   ./get_vast_secret.sh <resource_name> [tf_state_dir] [private_key_file] [output_dir]
#
# Parameters:
#   <resource_name>    = The suffix of the Terraform resource name. For example:
#                        If the full Terraform resource is `vastdata_user_key.s3key1`,
#                        pass only `s3key1` as the argument.
#
#   [tf_state_dir]     = Path to Terraform state directory
#                         Default: ~/Terraform/vastdata/cluster_config
#
#   [private_key_file] = Path to private PGP key file
#                         Default: ~/Terraform/vastdata/secrets/s3_pgp_private.asc
#
#   [output_dir]       = Directory where the extracted encrypted file will be saved
#                         Default: ~/Terraform/vastdata/secrets
#
# Example:
#   ./get_vast_secret.sh s3key1
#   ./get_vast_secret.sh s3key1 /custom/tf_dir /custom/key.asc /custom/output
#
# What this script does:
#   1. Imports the private PGP key (if not already imported)
#   2. Extracts the access key and encrypted secret key block from Terraform state
#   3. Cleans leading whitespace from the PGP block
#   4. Saves the cleaned block to an .asc file in the output directory
#   5. Decrypts it and prints both the access key and secret key
# ==============================================================================

set -e

# Parameters and defaults
RESOURCE_NAME="$1"
TF_DIR="${2:-$HOME/Terraform/vastdata/cluster_config}"
PRIVATE_KEY_FILE="${3:-$HOME/Terraform/vastdata/secrets/s3_pgp_private.asc}"
OUTPUT_DIR="${4:-$HOME/Terraform/vastdata/secrets}"

# Ensure resource name provided
if [ -z "$RESOURCE_NAME" ]; then
    echo "Usage: $0 <resource_name> [tf_state_dir] [private_key_file] [output_dir]"
    exit 1
fi

# Validate directories and files
if [ ! -d "$TF_DIR" ]; then
    echo "Error: Terraform directory not found: $TF_DIR"
    exit 1
fi

if [ ! -f "$PRIVATE_KEY_FILE" ]; then
    echo "Error: Private key file not found: $PRIVATE_KEY_FILE"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

ENCRYPTED_FILE="$OUTPUT_DIR/${RESOURCE_NAME}_encrypted.asc"

# Step 1: Import private key (if not already imported)
if ! gpg --list-secret-keys | grep -q "vast-s3@example.com"; then
    echo "Importing private key from ${PRIVATE_KEY_FILE}..."
    gpg --import "$PRIVATE_KEY_FILE" || { echo "Failed to import private key"; exit 1; }
fi

# Step 2: Extract access key and encrypted PGP block from Terraform state
ACCESS_KEY=$(
  cd "$TF_DIR"
  terraform state show "vastdata_user_key.${RESOURCE_NAME}" \
    | awk '/access_key/ {gsub(/"/,"",$3); print $3}'
)

(
  cd "$TF_DIR"
  terraform state show "vastdata_user_key.${RESOURCE_NAME}" \
    | awk '/-----BEGIN PGP MESSAGE-----/{flag=1} flag; /-----END PGP MESSAGE-----/{flag=0}' \
    | sed 's/^[ \t]*//' > "$ENCRYPTED_FILE"
)

if [ -z "$ACCESS_KEY" ]; then
    echo "Error: Failed to extract access key."
    exit 1
fi

if [ ! -s "$ENCRYPTED_FILE" ]; then
    echo "Error: Failed to extract encrypted secret key."
    exit 1
fi

# Step 3: Decrypt and clean output (strip headers and prompt)
SECRET=$(gpg --decrypt "$ENCRYPTED_FILE" 2>/dev/null | tr -d '\n' | awk '{print $NF}')

if [ -z "$SECRET" ]; then
    echo "Error: Failed to decrypt secret key."
    exit 1
fi

# Print results
echo "Access Key : $ACCESS_KEY"
echo "Secret Key : $SECRET"
