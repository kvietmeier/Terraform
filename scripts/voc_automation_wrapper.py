#!/usr/bin/env python3
###---------------------------------------------------------------------------------------###
# https://chatgpt.com/share/689501b5-ed08-800a-8ce9-248a61718dbb
#
# voc_automation_wrapper.py.sh
#
# This script automates the deployment and configuration of a VAST cluster using Terraform.
# It handles the following tasks:
# 1. Runs `terraform apply` in the cluster directory to deploy the VAST cluster.
# 2. Retrieves the VAST cluster's IP address from Terraform output.
# 3. Updates the `/etc/hosts` file with the VAST cluster's VMS IP and hostname.
# 4. Waits for the VAST cluster to become ONLINE by checking its state via the VAST API.
# 5. Runs `terraform apply` in the configuration directory to configure the VAST cluster.   
# Requirements:
# - Python 3.x
# - Terraform installed and configured
# - Sudo privileges to update `/etc/hosts`  
# This script assumes that the Terraform configuration files are located in the:
#  `./terraform/cluster` and `./terraform/configure` directories.
###---------------------------------------------------------------------------------------###


import subprocess
import json
import time
import requests
import urllib3
import sys
import shutil
import os

urllib3.disable_warnings()

# -------------------------------
# Configuration
# -------------------------------

TERRAFORM_CLUSTER_DIR = "./terraform/cluster"
TERRAFORM_CONFIG_DIR = "./terraform/configure"
DEFAULT_USERNAME = "admin"
DEFAULT_PASSWORD = "123456"
DEFAULT_HOSTNAME = "vms"
MAX_WAIT = 900  # seconds
POLL_INTERVAL = 30  # seconds

# -------------------------------
# Run Terraform Apply
# -------------------------------

def run_terraform_apply(directory):
    print(f"Running terraform apply in {directory}...")
    subprocess.run(["terraform", "init"], cwd=directory, check=True)
    subprocess.run(["terraform", "apply", "-auto-approve"], cwd=directory, check=True)

# -------------------------------
# Get Terraform Output
# -------------------------------

def get_terraform_output(directory, key):
    print(f"Retrieving Terraform output: {key}")
    result = subprocess.run(
        ["terraform", "output", "-json"],
        cwd=directory,
        stdout=subprocess.PIPE,
        check=True,
        text=True
    )
    outputs = json.loads(result.stdout)
    return outputs[key]['value']

# -------------------------------
# Update /etc/hosts
# -------------------------------

def update_etc_hosts(ip, hostname=DEFAULT_HOSTNAME):
    """
    Updates /etc/hosts with the given IP and hostname.

    Requirements:
      - sudo NOPASSWD access to /usr/bin/tee /etc/hosts
      - Adds or replaces any existing line for the hostname
      - Backs up /etc/hosts to /etc/hosts.bak
    """

    line = f"{ip} {hostname}\n"
    backup_path = "/etc/hosts.bak"

    try:
        # Backup the current /etc/hosts
        shutil.copy("/etc/hosts", backup_path)
        print(f"/etc/hosts backed up to {backup_path}")
    except Exception as e:
        print(f"Failed to back up /etc/hosts: {e}")
        sys.exit(1)

    try:
        # Read current /etc/hosts
        with open("/etc/hosts", "r") as f:
            lines = f.readlines()
    except Exception as e:
        print(f"Failed to read /etc/hosts: {e}")
        sys.exit(1)

    # Remove existing lines for the hostname
    new_lines = [l for l in lines if not l.strip().endswith(hostname)]
    new_lines.append(line)

    final_content = "".join(new_lines)

    try:
        # Write the updated content using sudo tee
        subprocess.run(
            ["sudo", "tee", "/etc/hosts"],
            input=final_content.encode(),
            check=True
        )
        print(f"/etc/hosts updated with: {ip} {hostname}")
    except subprocess.CalledProcessError:
        print("Failed to update /etc/hosts. Check your sudoers configuration.")
        sys.exit(1)

# -------------------------------
# Wait for Cluster to be ONLINE
# -------------------------------

def wait_for_cluster_online(ip, username, password):
    print(f"Waiting for VAST cluster at {ip} to become ONLINE...")
    base_url = f"https://{ip}/api/v5"
    token_url = f"{base_url}/token/"
    cluster_url = f"{base_url}/clusters/"

    auth_payload = {"username": username, "password": password}
    auth_headers = {"Content-Type": "application/json", "Accept": "*/*"}

    start_time = time.time()

    while time.time() - start_time < MAX_WAIT:
        try:
            auth_response = requests.post(token_url, json=auth_payload, headers=auth_headers, verify=False)
            if auth_response.status_code != 200:
                raise Exception("Authentication failed")

            token = auth_response.json()["access"]
            headers = {"Accept": "*/*", "Authorization": f"Bearer {token}"}

            cluster_response = requests.get(cluster_url, headers=headers, verify=False)
            cluster_response.raise_for_status()

            clusters = cluster_response.json()
            if clusters and isinstance(clusters, list):
                state = clusters[0].get("state", "UNKNOWN")
                print(f"Cluster state: {state}")
                if state == "ONLINE":
                    return True
        except Exception as e:
            print(f"Cluster not ready: {e}")

        time.sleep(POLL_INTERVAL)

    print("Timed out waiting for the cluster to become ONLINE.")
    return False

# -------------------------------
# Main Workflow
# -------------------------------

def main():
    try:
        run_terraform_apply(TERRAFORM_CLUSTER_DIR)

        vms_ip = get_terraform_output(TERRAFORM_CLUSTER_DIR, "vms_ip")

        update_etc_hosts(vms_ip, DEFAULT_HOSTNAME)

        if not wait_for_cluster_online(vms_ip, DEFAULT_USERNAME, DEFAULT_PASSWORD):
            print("Cluster did not become ONLINE. Exiting.")
            sys.exit(1)

        run_terraform_apply(TERRAFORM_CONFIG_DIR)

        print("Cluster deployed and configured successfully.")

    except subprocess.CalledProcessError as e:
        print(f"Terraform failed: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"Unexpected error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
