## Full End-To-End Configuration of a VAST Data Cluster

### VAST Data Cluster Lab Automation Engine

This repository contains a modular Terraform workflow orchestrated by an advanced automation orchestrator wrapper (`cluster_setup.sh`). It dynamically provisions VAST Data storage resources, POSIX data-plane identities, and matching interactive VMS management logins sequentially across up to 20 cluster infrastructure endpoints.

The system features:
* **Workspace Isolation via Symlinks:** Generates unique `work_<Cluster_Name>` runtime directories, symlinking core HCL modules from a centralized core block to isolate states and locks.
* **Dual-Plane Identity Synchronization:** Simultaneously provisions POSIX data-plane users/groups and VMS management-plane administrative manager accounts (`LOCAL_ADMIN`) bound to an immutable cluster security role.
* **Auto-Loading Master Variables:** Automatically mirrors your master variable definitions (`base-config/terraform.tfvars`) into each isolated workspace path, eradicating old evaluation conflicts caused by legacy `.auto.tfvars` overrides.
* **Sequential Processing:** Validates and fires the dependency engine only against targeted, active cluster tracking endpoints.

---

### Prerequisites

* **Terraform CLI** (`>= 1.5.0`) installed locally.
* **Network Line-of-Sight** to the VMS control plane IP endpoints listed in your tracking inventory file.
* **Correct Provider Binaries:** Ensure your workspace has access to the updated `vast-data/vastdata` provider supporting management-plane layout configurations.

---

### Project Architecture & Directories

```text
cluster_basic/
├── cluster_setup.sh         # Core automation orchestrator loop wrapper
├── cluster_list.txt         # Comma-separated cluster inventory (Name,IP)
└── base-config/             # Your master configuration template files (Source-of-Truth)
    ├── locals.tf            # Computes local variables and password string mappings
    ├── main.tf              # Storage view configuration layer (NFS & S3 targets)
    ├── outputs.tf           # Structured infrastructure return value maps
    ├── provider.tf          # Core VAST provider schema block
    ├── terraform.tfvars     # Master 10-user payload list variable configurations
    ├── users.tf             # Unified POSIX accounts, groups, and VMS managers manifest
    └── variables.tf         # Master typing schema constraints

```
