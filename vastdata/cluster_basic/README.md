```text
# Full End-to-End Configuration of a VAST Data Cluster

### VAST Data Cluster Lab Automation Engine

This repository contains a modular Terraform workflow orchestrated by an automation script wrapper (cluster_setup.sh). It provisions VAST Data configurations (Views, Tenants, Policies, Users, and Network VIP Pools) sequentially across a list of cluster infrastructure endpoints. It maintains isolated state files in a single remote bucket.

The system features:
* State Isolation: Maps distinct Google Cloud Storage (GCS) tracking prefixes per cluster target to prevent state file overwrites.
* Portable Directory Execution: Evaluates system environment path roots so the repository works across different local user profiles when cloned.
* Sequential Processing: Validates existing healthy clusters using the remote backend, applying changes only where configuration drift is detected.

---

### Prerequisites

* Terraform CLI (>= 1.5.0) installed locally.
* Google Cloud CLI (gcloud) authenticated to the project hosting the remote tracking bucket.
* Access to a Google Cloud Storage bucket (clouddev-itdesk124-tfstate) for state management.
* Network line-of-sight to the control IP endpoints listed in the tracking inventory file.

---

### Project Architecture & Directories

cluster_basic/
├── cluster_setup.sh         # The main automation script
├── cluster_list.txt         # Your cluster inventory list (StandardName,IP)
└── base-config/             # Your master configuration template files
    ├── locals.tf            # Computes dynamic values and mapping loops
    ├── main.tf              # Base infrastructure mapping for NFS and S3 targets
    ├── outputs.tf           # Structured return value maps
    ├── provider.tf          # Core VAST provider schema requirements
    ├── terraform.tfvars     # Reusable global variables payload
    ├── users.tf             # Definitions for POSIX users, groups, and tenants
    └── variables.tf         # Master typing schema constraints

---

### Core Automation Orchestrator Pipeline

The loop engine manages structural dependencies by reading profiles out of cluster_list.txt. It soft-links the master schemas into temporary local work_<Cluster_Name> directories, appends the explicit cluster endpoint credentials, and initializes the backend tracking dynamically.

#### Execution Lifecycle Commands

To run configuration deployments, scale additions, or check existing configurations:

  chmod +x cluster_setup.sh
  ./cluster_setup.sh --apply

To clean tear down and permanently erase all infrastructure resources for the targets currently tracking in your file inventory:

  ./cluster_setup.sh --destroy

---

### Inventory Map Matrix (cluster_list.txt)

Populate your cluster target systems using a comma-separated format (StandardName,IP_or_FQDN). The script uses the standard descriptive label to structure your workspace paths and GCS cloud buckets, and uses the IP address to bind network connections:

  lab-cluster-01,10.129.12.10
  lab-cluster-02,10.129.12.11
  lab-cluster-03,10.129.12.12

---

### Key Resources & Schema Coverage

* vastdata_tenant: Provisions multi-tenant sandbox isolations.
* vastdata_group: Outlines POSIX system user group parameters.
* vastdata_user: Provisions programmatic users with GID/UID maps.
* vastdata_vip_pool: Assigns flat IP ranges to specific client routing protocols.
* vastdata_view_policy: Configures protocol characteristics (NFS, S3, Mixed-Mode).
* vastdata_view: Provisions data pathways, mount points, and S3 buckets.
* vastdata_user_key: Uploads PGP-armored keys for S3 user identity access.

---

## Technical Notes & Architecture Learnings

* Explicit Provider Aliasing: Resources must map to an explicitly aliased provider target (e.g., alias = "GCPCluster") inside the working environment. Omitting the aliased provider configuration causes the compilation runtime to search for a default, non-existent hashicorp/vastdata provider block instead of the correct vast-data/vastdata source namespace.

* The Multi-Tenancy Boundary Constraint: When provisioning isolated environments using vastdata_tenant, you must explicitly pass tenant_id mappings into your vastdata_view_policy and vastdata_view blocks. Omitting the tenant identification tag defaults resources to the Global Tenant environment context, rendering your intended multi-tenant design empty.

* Dynamic Backend Partial Configurations: Leaving the backend "gcs" {} container configuration block empty inside the master files allows you to input custom bucket destinations and dynamic object target tracking fields (-backend-config="prefix=...") during the command line initialization phase.

---

#### Author

* Karl Vietmeier

#### License

This project is licensed under the Apache License. See the LICENSE.md file for details.

#### Acknowledgments

* Josh Wentzel for getting me started down this path.

```