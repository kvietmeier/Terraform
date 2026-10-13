#!/usr/bin/env python3
# ============================================================================
#  VAST Data Cloud Cluster Automation Script
#
#  Author: Karl Vietmeier
#
#  Overview:
#    End-to-end cloud cluster bring-up living under vastdata/devops_cluster/:
#    Stage 1 provisions infra via vastcloud; this script captures endpoints from
#    Terraform outputs, polls until ONLINE, waits for VMS settle, then applies
#    config/ Terraform. Extracted S3 keys land in secrets/.
#
#    Workflow:
#      1. Stage 1 — vastcloud cluster create (CLI log redirected to disk; UX only).
#      2. Capture endpoints from cloud Terraform outputs under
#         ~/.vast/clusters/<name>/terraform/<provider>/… — baseline truth.
#      3. Poll VAST API until ONLINE (up to 60 minutes).
#      4. Wait 5 minutes for database synchronization.
#      5. Clean / reinit and apply ./config Terraform.
#      6. Extract/decrypt S3 keys into ./secrets and print an access guide.
#
#  Stage 1 env (or --create-env KEY=VALUE file):
#    VAST_CLUSTER_NAME, VAST_CLOUD_PROVIDER, VAST_SUBNET (required)
#    AWS: VAST_AWS_SG_IDS, VAST_AWS_REGION, VAST_AWS_ZONE
#    GCP: VAST_GCP_PROTOCOL_VIPS, VAST_GCP_REGION, VAST_GCP_ZONE
#         optional: VAST_GCP_PROJECT_ID, VAST_GCP_SA_EMAIL
#    VAST_SKIP_CREATE=1         skip create; capture + poll + config only
#
#  Defaults (override with env):
#    config/   next to this script
#    secrets/  next to this script
#    *.auto.tfvars in config/ are auto-loaded by Terraform
#
#  License:
#    Copyright (c) 2026 Karl Vietmeier
# ============================================================================

import argparse
import subprocess
import time
import os
import sys
import json
import requests
import urllib3
import ipaddress
import re
from pathlib import Path
from urllib.parse import urlparse

urllib3.disable_warnings()

_HOME = os.path.expanduser("~")
_SCRIPT_DIR = Path(__file__).resolve().parent

# --- Defaults (overridden after env-file load / CLI parse) ---
USERNAME = os.getenv("VAST_USERNAME", "admin")
PASSWORD = os.getenv("VAST_PASSWORD", "123456")
CHECK_INTERVAL = 180    # 3 minutes
MAX_WAIT = 60 * 60      # 60 minutes
POST_ONLINE_WAIT = 300  # 5 minutes

# --- Helpers ---
script_start = time.time()

def elapsed_minutes(start_time):
    return round((time.time() - start_time) / 60, 1)

def log_stage(msg, start_time=None):
    if start_time:
        print(f"[+{elapsed_minutes(start_time)}m] {msg}", flush=True)
    else:
        print(msg, flush=True)

def load_env_file(path):
    """Load KEY=VALUE lines into os.environ (does not override existing vars)."""
    path = Path(path).expanduser()
    if not path.is_file():
        print(f"ERROR: create env file not found: {path}", file=sys.stderr)
        sys.exit(1)
    with path.open() as fh:
        for lineno, raw in enumerate(fh, 1):
            line = raw.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            key, _, value = line.partition("=")
            key = key.strip()
            value = value.strip().strip('"').strip("'")
            if not key:
                print(f"ERROR: bad env line {path}:{lineno}", file=sys.stderr)
                sys.exit(1)
            os.environ.setdefault(key, value)

def cluster_home(cluster_name):
    return Path(os.path.expanduser(f"~/.vast/clusters/{cluster_name}"))

def resolve_paths(cluster_name, cloud_provider):
    """Resolve cloud TF dir, config dir, secrets dir (defaults: this project)."""
    tf_dir = os.getenv(
        "VAST_TF_DIR",
        str(cluster_home(cluster_name) / "terraform" / cloud_provider / "voc"),
    )
    config_dir = os.getenv("VAST_CONFIG_DIR", str(_SCRIPT_DIR / "config"))
    # Empty default: rely on config/*.auto.tfvars auto-load; set VAST_TFVARS_FILE to force -var-file.
    tfvars = os.getenv("VAST_TFVARS_FILE", "").strip()
    secrets = os.getenv("VAST_SECRETS_DIR", str(_SCRIPT_DIR / "secrets"))
    return tf_dir, config_dir, tfvars, secrets

def build_vastcloud_create_cmd(cluster_name, cloud_provider):
    """Build non-interactive vastcloud create; fail fast on missing required args."""
    subnet = os.getenv("VAST_SUBNET", "").strip()
    missing = []
    if not cluster_name:
        missing.append("VAST_CLUSTER_NAME")
    if not subnet:
        missing.append("VAST_SUBNET")

    cmd = [
        "vastcloud", "cluster", "create",
        "--select", cluster_name,
        "--non-interactive",
        "--force",
        "--skip-preflight",
        "--skip-checker",
        "--subnet", subnet,
    ]

    if cloud_provider == "aws":
        sg_ids = os.getenv("VAST_AWS_SG_IDS", "").strip()
        region = os.getenv("VAST_AWS_REGION", "").strip()
        zone = os.getenv("VAST_AWS_ZONE", "").strip()
        if not sg_ids:
            missing.append("VAST_AWS_SG_IDS")
        if not region:
            missing.append("VAST_AWS_REGION")
        if not zone:
            missing.append("VAST_AWS_ZONE")
        if missing:
            print(f"ERROR: missing create env: {', '.join(missing)}", file=sys.stderr)
            sys.exit(1)
        cmd.extend([
            "--aws-security-group-ids", sg_ids,
            "--region", region,
            "--zone", zone,
        ])
    elif cloud_provider == "gcp":
        vips = os.getenv("VAST_GCP_PROTOCOL_VIPS", "").strip()
        region = os.getenv("VAST_GCP_REGION", "").strip()
        zone = os.getenv("VAST_GCP_ZONE", "").strip()
        if not vips:
            missing.append("VAST_GCP_PROTOCOL_VIPS")
        if not region:
            missing.append("VAST_GCP_REGION")
        if not zone:
            missing.append("VAST_GCP_ZONE")
        if missing:
            print(f"ERROR: missing create env: {', '.join(missing)}", file=sys.stderr)
            sys.exit(1)
        cmd.extend([
            "--protocol-vips", vips,
            "--region", region,
            "--zone", zone,
        ])
        project = os.getenv("VAST_GCP_PROJECT_ID", "").strip()
        sa_email = os.getenv("VAST_GCP_SA_EMAIL", "").strip()
        if project:
            cmd.extend(["--gcp-project-id", project])
        if sa_email:
            cmd.extend(["--gcp-service-account-email", sa_email])
    else:
        print(f"ERROR: VAST_CLOUD_PROVIDER must be aws or gcp (got '{cloud_provider}')",
              file=sys.stderr)
        sys.exit(1)

    return cmd

# Console-only milestones from the real vastcloud create stream (full log stays on disk).
_CREATE_MILESTONE_RES = [
    re.compile(r"Successfully created Terraform-backed cluster", re.I),
    re.compile(r"^Private IP Address:\s*", re.I),
    re.compile(r"^Management URL:\s*", re.I),
    re.compile(r"^Monitor URL:\s*", re.I),
    re.compile(r"Finished with management IP:", re.I),
    re.compile(r"Cluster provisioning complete", re.I),
    re.compile(r"Done, VMS is up", re.I),
    re.compile(r"VMS installation completed", re.I),
    re.compile(r"Cluster is ready!", re.I),
    re.compile(r"Cluster is now ready:", re.I),
    re.compile(r"Done with apply on Terraform", re.I),
    re.compile(r"=== Connected to log stream ==="),
    re.compile(r"Waiting for cluster to be ready", re.I),
]

_CREATE_HEARTBEAT_SECS = 180  # quiet progress while install stream runs (often 20–40m)

def _is_create_milestone(line):
    text = line.strip().strip('"').strip("'").strip(",")
    if not text:
        return False
    return any(rx.search(text) for rx in _CREATE_MILESTONE_RES)

def run_vastcloud_cli(cluster_name, cloud_provider, dry_run=False):
    """
    Stage 1: run vastcloud create.

    The CLI is extremely verbose (TF apply + install log stream). Full output
    goes to ~/.vast/clusters/<name>/logs/vastcloud-create.log for operator
    debugging only — not a stable interface. Endpoints are captured from VOC
    Terraform outputs after create exits.
    """
    cmd = build_vastcloud_create_cmd(cluster_name, cloud_provider)
    log_path = cluster_home(cluster_name) / "logs" / "vastcloud-create.log"
    preview = " ".join(cmd)

    if dry_run:
        print(f"Dry-run Stage 1 command:\n  {preview}")
        print(f"Would redirect stdout/stderr -> {log_path}")
        return log_path

    log_path.parent.mkdir(parents=True, exist_ok=True)
    stage_start = time.time()
    print(f"--- Stage 1: vastcloud create ({cluster_name}) ---")
    print(f"  log: {log_path}")
    print(f"  cmd: {preview}")

    with log_path.open("w") as log_fh:
        log_fh.write(f"# cmd: {preview}\n")
        log_fh.flush()
        proc = subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            bufsize=1,
        )
        last_heartbeat = time.time()
        assert proc.stdout is not None
        for line in proc.stdout:
            log_fh.write(line)
            log_fh.flush()
            # Milestones are UX-only (CLI text is not an API).
            if _is_create_milestone(line):
                log_stage(line.rstrip(), stage_start)
                last_heartbeat = time.time()
            elif time.time() - last_heartbeat >= _CREATE_HEARTBEAT_SECS:
                log_stage("vastcloud create still running (see log)...", stage_start)
                last_heartbeat = time.time()
        rc = proc.wait()

    if rc != 0:
        print(
            f"ERROR: vastcloud create failed (exit {rc}). See {log_path}",
            file=sys.stderr,
        )
        try:
            tail = "\n".join(log_path.read_text(errors="replace").splitlines()[-40:])
            if tail:
                print("--- log tail ---", file=sys.stderr)
                print(tail, file=sys.stderr)
        except OSError:
            pass
        sys.exit(rc)

    log_stage("vastcloud create exited 0 — capturing from Terraform outputs", stage_start)
    return log_path

def _host_from_url(url):
    if not url:
        return None
    parsed = urlparse(url if "://" in url else f"https://{url}")
    return parsed.hostname

def capture_cluster_endpoints(cluster_name, tf_dir):
    """
    After Stage 1, collect endpoints from cloud Terraform outputs (baseline truth).

    Preferred outputs under ~/.vast/clusters/<name>/terraform/<provider>/… :
      vms_ip, dns_vip, preallocated_protocol_vips | protocol_vips | vip_pool_ips
      vip_pool_cidr (legacy fallback for dns host derivation)

    Writes capture.json for later stages. vastcloud CLI / log text is not a data source.
    """
    home = cluster_home(cluster_name)

    if not os.path.isdir(tf_dir):
        print(f"ERROR: VOC Terraform directory not found: {tf_dir}", file=sys.stderr)
        sys.exit(1)

    try:
        vms_ip = get_terraform_output(tf_dir, "vms_ip")
        dns_vip = get_terraform_output(tf_dir, "dns_vip")
        vip_cidr = get_terraform_output(tf_dir, "vip_pool_cidr")
        vip_ips = get_terraform_output(tf_dir, "vip_pool_ips")
        proto = get_terraform_output(tf_dir, "protocol_vips")
        prealloc = get_terraform_output(tf_dir, "preallocated_protocol_vips")
        private_ips = get_terraform_output(tf_dir, "private_ips")
        mgmt_url = get_terraform_output(tf_dir, "mgmt_url") or get_terraform_output(
            tf_dir, "cluster_mgmt"
        )
    except (subprocess.CalledProcessError, json.JSONDecodeError) as exc:
        print(f"ERROR: terraform output failed in {tf_dir}: {exc}", file=sys.stderr)
        sys.exit(1)

    protocol_vips = []
    if isinstance(vip_ips, list) and vip_ips:
        protocol_vips = vip_ips
    elif isinstance(proto, list) and proto:
        protocol_vips = proto
    elif isinstance(prealloc, (list, set)) and prealloc:
        protocol_vips = list(prealloc)

    private_ip = None
    if isinstance(private_ips, list) and private_ips:
        private_ip = private_ips[0]

    if not vms_ip and mgmt_url:
        vms_ip = _host_from_url(mgmt_url)

    if not vms_ip:
        print(
            f"ERROR: terraform output 'vms_ip' missing in {tf_dir} "
            "(and mgmt_url/cluster_mgmt not usable)",
            file=sys.stderr,
        )
        sys.exit(1)

    # TF_VAR_vms_host: prefer dns_vip; else derive .253 from vip CIDR if present.
    if dns_vip:
        vms_host = dns_vip
    elif vip_cidr:
        vms_host = get_dns_ip_from_cidr(vip_cidr)
    else:
        vms_host = vms_ip
        log_stage("WARNING: no dns_vip/vip_pool_cidr in TF outputs; "
                  "TF_VAR_vms_host falls back to vms_ip")

    management_url = mgmt_url or f"https://{vms_ip}"

    capture = {
        "cluster_name": cluster_name,
        "vms_ip": vms_ip,
        "private_ip": private_ip,
        "dns_vip": dns_vip,
        "vms_host": vms_host,
        "vip_cidr": vip_cidr,
        "protocol_vips": protocol_vips,
        "management_url": management_url,
        "tf_dir": tf_dir,
    }
    capture_path = home / "capture.json"
    home.mkdir(parents=True, exist_ok=True)
    capture_path.write_text(json.dumps(capture, indent=2) + "\n")
    log_stage(f"Captured endpoints from Terraform -> {capture_path}")
    log_stage(f"  VMS IP     : {vms_ip}")
    if private_ip:
        log_stage(f"  Private IP : {private_ip}")
    log_stage(f"  TF_VAR host: {vms_host}")
    if protocol_vips:
        log_stage(f"  Protocol   : {', '.join(protocol_vips)}")
    return capture

def run_terraform_apply(path, extra_args=None):
    """Executes terraform apply for Stage 4 configuration."""
    args = ["terraform", "apply", "-auto-approve"]
    if extra_args:
        args.extend(extra_args)
    subprocess.run(args, cwd=path, check=True)

def get_terraform_output(path, key):
    """Extracts a specific output variable from Terraform/vastcloud state."""
    result = subprocess.run(
        ["terraform", "output", "-json"],
        cwd=path,
        check=True,
        capture_output=True,
        text=True
    )
    outputs = json.loads(result.stdout)
    return outputs.get(key, {}).get("value")

def get_dns_ip_from_cidr(cidr_str):
    """Calculates the .253 IP from a CIDR, or falls back to the last usable IP."""
    try:
        network = ipaddress.IPv4Network(cidr_str, strict=False)
        octets = str(network.network_address).split('.')
        candidate_ip_str = f"{octets[0]}.{octets[1]}.{octets[2]}.253"
        candidate_ip = ipaddress.IPv4Address(candidate_ip_str)
        
        if candidate_ip in network.hosts():
            return candidate_ip_str
            
        return str(list(network.hosts())[-1])
    except ValueError as e:
        print(f"ERROR: Invalid CIDR format '{cidr_str}': {e}", file=sys.stderr)
        sys.exit(1)

def get_vms_state(ip, username=USERNAME, password=PASSWORD):
    base_url = f"https://{ip}/api/v5"
    token_url = f"{base_url}/token/"
    cluster_url = f"{base_url}/clusters/"
    try:
        auth_resp = requests.post(
            token_url,
            json={"username": username, "password": password},
            headers={"Content-Type": "application/json"},
            verify=False,
            timeout=(3,5)
        )
        auth_resp.raise_for_status()
        token = auth_resp.json()['access']
    except Exception:
        return "OFFLINE"

    try:
        cluster_resp = requests.get(
            cluster_url,
            headers={"Authorization": f"Bearer {token}"},
            verify=False,
            timeout=(3,5)
        )
        cluster_resp.raise_for_status()
        clusters = cluster_resp.json()
        if clusters and isinstance(clusters, list):
            return clusters[0].get("state", "UNKNOWN")
        return "UNKNOWN"
    except Exception:
        return "OFFLINE"

def wait_for_online(ip, username=USERNAME, password=PASSWORD):
    start_time = time.time()
    deadline = start_time + MAX_WAIT
    last_state = None
    state_start = start_time

    while time.time() < deadline:
        state = get_vms_state(ip, username, password)

        if state != last_state:
            duration = round((time.time() - state_start)/60,1)
            if last_state is None:
                log_stage(f"VMS state: {state}", start_time)
            else:
                log_stage(f"Transition: {last_state} → {state} ({duration} min)", start_time)
            last_state = state
            state_start = time.time()

        if state == "ONLINE":
            total = elapsed_minutes(start_time)
            log_stage(f"✔ VMS reached ONLINE in {total} minutes", start_time)
            return True, total

        log_stage(f"VMS not ready yet (state={state}), waiting...", start_time)
        time.sleep(CHECK_INTERVAL)

    log_stage("ERROR: VMS did not reach ONLINE within max wait", start_time)
    return False, elapsed_minutes(start_time)

def clean_and_init_terraform(path):
    print(f"Cleaning Terraform state in {path}")
    subprocess.run(
        "find . -type d -name '.terraform' -exec rm -rf {} +",
        cwd=path,
        shell=True,
        check=True
    )
    for f in ["terraform.tfstate", "terraform.tfstate.backup"]:
        try:
            os.remove(os.path.join(path, f))
        except FileNotFoundError:
            pass

    print("Re-initializing Terraform...")
    subprocess.run(["terraform", "init", "-upgrade"], cwd=path, check=True)

def extract_s3_keys(tf_dir, output_dir):
    """Extracts and decrypts S3 keys, returning them for final output."""
    print(f"\n--- Extracting S3 Keys to {output_dir} ---")
    os.makedirs(output_dir, exist_ok=True)
    extracted_creds = []
    
    state_list = subprocess.run(
        ["terraform", "state", "list"], cwd=tf_dir, capture_output=True, text=True, check=True
    ).stdout
    
    resources = re.findall(r'(vastdata_user_key\.s3keys\["([^"]+)"\])', state_list)
    
    if not resources:
        print("No S3 user keys found in Terraform state.")
        return extracted_creds

    for resource_name, username in resources:
        state_show = subprocess.run(
            ["terraform", "state", "show", resource_name], 
            cwd=tf_dir, capture_output=True, text=True, check=True
        ).stdout
        
        access_key_match = re.search(r'access_key\s*=\s*"([^"]+)"', state_show)
        pgp_match = re.search(r'(-----BEGIN PGP MESSAGE-----.*?-----END PGP MESSAGE-----)', state_show, re.DOTALL)
        
        if not access_key_match or not pgp_match:
            continue
            
        access_key = access_key_match.group(1)
        pgp_block_clean = "\n".join([line.strip() for line in pgp_match.group(1).splitlines()])
        
        try:
            gpg_process = subprocess.run(
                ["gpg", "--decrypt"], input=pgp_block_clean, capture_output=True, text=True, check=True
            )
            secret_key = gpg_process.stdout.split()[-1]
            
            output_file = os.path.join(output_dir, f"{username}.txt")
            with open(output_file, "w") as f:
                f.write(f"Access Key: {access_key}\nSecret Key: {secret_key}\n")
            
            extracted_creds.append((username, access_key, secret_key))
            
        except subprocess.CalledProcessError:
            pass
            
    return extracted_creds

def parse_args():
    p = argparse.ArgumentParser(
        description="vastcloud create → capture → ONLINE poll → config Terraform",
    )
    p.add_argument(
        "--create-env",
        metavar="FILE",
        help="KEY=VALUE file for Stage 1 create args (does not override existing env)",
    )
    p.add_argument(
        "--skip-create",
        action="store_true",
        help="Skip Stage 1; capture from existing ~/.vast/clusters/<name> and continue",
    )
    p.add_argument(
        "--dry-run",
        action="store_true",
        help="Print Stage 1 command / log path only, then exit",
    )
    p.add_argument(
        "--cluster",
        help="Override VAST_CLUSTER_NAME (Polaris --select name)",
    )
    p.add_argument(
        "--provider",
        choices=("aws", "gcp"),
        help="Override VAST_CLOUD_PROVIDER",
    )
    return p.parse_args()

def main():
    args = parse_args()
    if args.create_env:
        load_env_file(args.create_env)

    cluster_name = args.cluster or os.getenv("VAST_CLUSTER_NAME", "").strip()
    cloud_provider = (args.provider or os.getenv("VAST_CLOUD_PROVIDER", "")).strip().lower()
    skip_create = args.skip_create or os.getenv("VAST_SKIP_CREATE", "").strip() in ("1", "true", "yes")

    if not cluster_name:
        print("ERROR: set VAST_CLUSTER_NAME, --cluster, or --create-env", file=sys.stderr)
        sys.exit(1)
    if not cloud_provider:
        # Infer from cluster.json when skipping create
        meta_path = cluster_home(cluster_name) / "cluster.json"
        if skip_create and meta_path.is_file():
            cloud_provider = json.loads(meta_path.read_text()).get("provider", "").lower()
    if cloud_provider not in ("aws", "gcp"):
        print("ERROR: set VAST_CLOUD_PROVIDER or --provider to aws|gcp", file=sys.stderr)
        sys.exit(1)

    vast_tf_dir, config_dir, tfvars_file, output_dir = resolve_paths(cluster_name, cloud_provider)

    # Stage 1: vastcloud create (verbose output on disk)
    if args.dry_run:
        run_vastcloud_cli(cluster_name, cloud_provider, dry_run=True)
        return

    if skip_create:
        print(f"--- Stage 1 skipped (using existing cluster {cluster_name}) ---")
    else:
        stage_start = time.time()
        create_log = run_vastcloud_cli(cluster_name, cloud_provider)
        log_stage(
            f"✔ vastcloud provisioning completed in {elapsed_minutes(stage_start)} minutes "
            f"(log: {create_log})"
        )

    # Capture endpoints from VOC Terraform outputs only
    capture = capture_cluster_endpoints(cluster_name, vast_tf_dir)
    vms_ip = capture["vms_ip"]
    os.environ["TF_VAR_vms_host"] = capture["vms_host"]

    # Stage 2: Wait for ONLINE
    print(f"--- Waiting for VMS at {vms_ip} to reach ONLINE ---")
    online, _wait_time = wait_for_online(vms_ip)
    if not online:
        sys.exit(1)

    # Stage 3: Post-online wait
    stage3_start = time.time()
    print(f"--- Cluster ONLINE, waiting {POST_ONLINE_WAIT // 60} minutes before config apply ---")
    time.sleep(POST_ONLINE_WAIT)
    log_stage(f"✔ Waited {elapsed_minutes(stage3_start)} minutes after ONLINE")

    # Stage 4: Configuration via Terraform (./config)
    stage4_start = time.time()
    print(f"--- Running configuration terraform apply in {config_dir} ---")
    clean_and_init_terraform(config_dir)
    extra = ["-var-file", tfvars_file] if tfvars_file else None
    run_terraform_apply(config_dir, extra)
    log_stage(f"✔ Configuration apply completed in {elapsed_minutes(stage4_start)} minutes")

    # Stage 5: Final Output Generation
    s3_credentials = extract_s3_keys(config_dir, output_dir)
    vip_ips = capture.get("protocol_vips") or [capture["vms_host"]]

    mount_target_ip = vip_ips[0]
    remoteports_str = ",".join(vip_ips)

    try:
        final_ip = get_terraform_output(config_dir, "vms_ip") or vms_ip
    except (subprocess.CalledProcessError, json.JSONDecodeError):
        final_ip = vms_ip
    total_elapsed = elapsed_minutes(script_start)

    print("\n=======================================================")
    print("                 Workflow Complete")
    print("=======================================================")
    print(f"   VMS Management IP     : https://{final_ip}")
    print(f"   Total Elapsed Time    : {total_elapsed} minutes")
    print("\n-------------------------------------------------------")
    print("   HOW TO ACCESS THIS CLUSTER")
    print("-------------------------------------------------------")

    print("\n   [ S3 Storage ]")
    if s3_credentials:
        for user, ak, sk in s3_credentials:
            print(f"   • User: {user}")
            print(f"       export AWS_ACCESS_KEY_ID={ak}")
            print(f"       export AWS_SECRET_ACCESS_KEY={sk}")
            print(f"       aws s3 ls --endpoint-url http://{mount_target_ip} --no-verify-ssl")
    else:
        print("   • No S3 keys were extracted.")

    print("\n   [ NFS Mounts ]")
    print("   • Standard NFS:")
    print(f"       sudo mount -t nfs -o vers=3 {mount_target_ip}:/ /mnt/vast")
    print("   • VAST NFS (Multipath):")
    print(f"       sudo mount -t nfs -o vers=3,remoteports={remoteports_str} {mount_target_ip}:/ /mnt/vast")

    print("\n   [ SMB / CIFS ]")
    print("   • Windows / UNC Path:")
    print(f"       \\\\{mount_target_ip}\\<share_name>")
    print("   • Linux CIFS Mount:")
    print(f"       sudo mount -t cifs //{mount_target_ip}/<share_name> /mnt/vast -o username=<user>")
    print("=======================================================\n")

if __name__ == "__main__":
    main()