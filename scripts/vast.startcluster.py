#!/usr/bin/env python3
"""
================================================================================
Terraform Apply + /etc/hosts Updater (Minimal sudo, passwordless)
================================================================================
Runs `terraform apply` for a given cluster and updates `/etc/hosts` so that 
the hostname `vms` resolves to the Terraform output `vms_ip`.

Only the `/etc/hosts` update step uses sudo — the rest runs as a normal user.

USAGE:
  python3 update_vms_ip_after_apply.py

NOTES:
  - Assumes user has passwordless sudo for writing /etc/hosts.
  - Terraform must be initialized in the target directory.
  - Adjust VALID_CLUSTERS and tf_dir path as needed.
================================================================================
"""

import subprocess
import os
import re
import sys

VALID_CLUSTERS = ["cluster01", "cluster02", "cluster03"]

def tf_output(tf_dir, name):
    """Run terraform output -raw <name> and return stripped value."""
    result = subprocess.run(
        ["terraform", "output", "-raw", name],
        cwd=tf_dir,
        capture_output=True,
        text=True
    )
    if result.returncode != 0:
        return None
    return result.stdout.strip()

def run_terraform_apply(tf_dir):
    """Run terraform apply with live log streaming."""
    process = subprocess.Popen(
        ["terraform", "apply", "-auto-approve"],
        cwd=tf_dir,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True
    )

    for line in process.stdout:
        print(line, end="")  # real-time log streaming

    process.wait()
    return process.returncode == 0

def update_hosts_with_sudo(ip, entry_name="vms", hosts_file="/etc/hosts"):
    """Update or append /etc/hosts entry for the given IP using sudo for write."""
    # Read current hosts file
    try:
        with open(hosts_file, "r") as f:
            lines = f.readlines()
    except FileNotFoundError:
        lines = []

    ip_pattern = re.compile(rf"^\d+\.\d+\.\d+\.\d+\s+{entry_name}\s*$")

    updated = False
    for i, line in enumerate(lines):
        if ip_pattern.match(line.strip()):
            lines[i] = f"{ip}\t{entry_name}\n"
            updated = True
            break

    if not updated:
        lines.append(f"{ip}\t{entry_name}\n")

    # Write updated hosts file using sudo tee (passwordless)
    joined_lines = "".join(lines)
    proc = subprocess.run(
        ["sudo", "tee", hosts_file],
        input=joined_lines,
        text=True,
        capture_output=True
    )
    if proc.returncode != 0:
        print("Failed to update /etc/hosts. Error:", proc.stderr)
        sys.exit(1)

def main():
    cluster_name = input("Enter cluster name (default: cluster01): ").strip() or "cluster01"

    if cluster_name not in VALID_CLUSTERS:
        print(f"Invalid cluster name. Valid options: {', '.join(VALID_CLUSTERS)}")
        sys.exit(1)

    tf_dir = os.path.expanduser(f"~/Terraform/vast_on_cloud/5_3/1861115-h5-beta1/{cluster_name}")
    if not os.path.isdir(tf_dir):
        print(f"Error: Directory not found: {tf_dir}")
        sys.exit(1)

    print(f"Running terraform apply in {tf_dir}...\n")
    if not run_terraform_apply(tf_dir):
        print("Terraform apply failed.")
        sys.exit(1)

    # Get outputs
    vms    = tf_output(tf_dir, "cluster_mgmt")
    vmsmon = tf_output(tf_dir, "vms_monitor")
    vmsip  = tf_output(tf_dir, "vms_ip")

    if not vmsip:
        print("Error: Could not retrieve vms_ip from terraform output.")
        sys.exit(1)

    print(f"\nUpdating /etc/hosts for {vmsip} -> vms...\n")
    update_hosts_with_sudo(vmsip, "vms")

    # Print outputs
    print("-" * 80)
    print(f"Terraform outputs in {tf_dir}:")
    print(f"vms    (cluster_mgmt): {vms}")
    print(f"vmsmon (vms_monitor) : {vmsmon}")
    print(f"vmsip  (vms_ip)      : {vmsip}")
    print("-" * 80)

if __name__ == "__main__":
    main()
