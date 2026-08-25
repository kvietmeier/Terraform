## VAST Data Cluster Lab Automation Engine

This repository contains a modular Terraform workflow orchestrated by an automation wrapper (`cluster_setup.sh`). It dynamically provisions many VAST Clusters with basic lab resources; NFS view/policies, users, and tenants. It is designed to be used wih VAST on Cloud clusters created with Polaris so VIP Pools, DNS, and Active Direct ory are not configured.

The system features:

* **Workspace Isolation via Symlinks:** Generates unique `work_<Cluster_Name>` runtime directories, symlinking core HCL modules from a centralized core block to isolate states and locks.
* **Identity Synchronization:** Simultaneously provisions users/groups and VMS management-plane administrative manager accounts (`LOCAL_ADMIN`) bound to an immutable cluster security role.
* **Auto-Loading Master Variables:** Automatically mirrors your master variable definitions (`base-config/terraform.tfvars`) into each isolated workspace path.
* **Sequential Processing:** Runs against a targeted set active clusters.

---

### Prerequisites

* **Terraform CLI** (`>= 1.5.0`) installed locally.
* **Network Line-of-Sight** to the VMS IPs listed in your tracking inventory file.

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
