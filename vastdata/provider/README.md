# Using environment variables for the Terraform Provider

Combining a default provider with an optional aliased provider in a single `provider.tf` creates a fully portable, environment-driven file. You can drop this standalone file into any new testing directory or reference it across multiple folders using a symbolic link.

---

## Overview of the Solution

This pattern completely decouples your provider authentication from your infrastructure code. By combining native provider environment variables with Terraform's `TF_VAR_` mapping, your test folders remain clean, modular, and instantly executable.

**Development Steps:**

1. **Define Default Provider:** Configure an un-aliased `provider "vastdata" {}` block so 90% of your scratchpad resources execute without needing explicit `provider = ...` tags.
2. **Define Aliased Provider:** Include `alias = "GCPCluster"` inside a secondary provider block for multi-cluster testing.
3. **Map Shell Inputs:** Declare input variables (`vast_username`, `vast_password`, etc.) so `TF_VAR_` environment variables automatically hydrate both provider blocks.
4. **Enable Symlink Portability:** Store one master `provider.tf` centrally and link it dynamically into any scratch workspace.

**Assumptions & Restrictions:**

- Your shell environment variables (`VASTDATA_HOST`, `TF_VAR_vast_username`, etc.) must be sourced in your terminal prior to running `terraform init` or `terraform plan`.
- If a resource omits `provider = ...`, Terraform defaults to the un-aliased provider block.

---

### Code Implementation

#### Set Environment variables in shell startup file/s

Run these commands in your shell to load credentials without storing them in `.tf` files.

```bash
# ==============================================================================
# Environment Variables for Aliased VAST Provider
# ==============================================================================

# Native provider fallbacks
export VASTDATA_HOST="10.10.20.74"
export VASTDATA_PORT="443"
export VASTDATA_TENANT="default"

# Mapped via TF_VAR_ prefix into Terraform variables
export TF_VAR_vast_username="admin"
export TF_VAR_vast_password="YourSecurePassword123"
export TF_VAR_vast_skip_ssl_verify="true"
export TF_VAR_vast_version_validation_mode="warn"
```

#### Self contained `provider.tf`

This file configures the aliased provider and maps the `TF_VAR_` shell inputs.

```hcl
# ==============================================================================
# Standalone VAST Data Provider Configuration
# Drop this file into any folder or symlink it from a central location.
# ==============================================================================

terraform {
  required_providers {
    vastdata = {
      source  = "vast-data/vastdata"
      version = "3.2.2"
    }
  }
}

# -------------------------------------------------------------------------
# Environment Variable Declarations (Populated via TF_VAR_ shell exports)
# -------------------------------------------------------------------------

variable "vast_username" {
  type      = string
  default   = null
  sensitive = true
}

variable "vast_password" {
  type      = string
  default   = null
  sensitive = true
}

variable "vast_skip_ssl_verify" {
  type    = bool
  default = true
}

variable "vast_version_validation_mode" {
  type    = string
  default = "warn"
}

variable "gcp_host" {
  type    = string
  default = null
}

# -------------------------------------------------------------------------
# 1. DEFAULT PROVIDER
# Standard resources automatically use this without needing 'provider = ...'
# -------------------------------------------------------------------------
provider "vastdata" {
  # Auto-reads VASTDATA_HOST, VASTDATA_PORT, VASTDATA_TENANT from shell
  username                = var.vast_username
  password                = var.vast_password
  skip_ssl_verify         = var.vast_skip_ssl_verify
  version_validation_mode = var.vast_version_validation_mode
}

# -------------------------------------------------------------------------
# 2. ALIASED PROVIDER
# Opt-in for multi-cluster or GCP-specific testing
# -------------------------------------------------------------------------
provider "vastdata" {
  alias                   = "GCPCluster"
  host                    = var.gcp_host != null ? var.gcp_host : null
  username                = var.vast_username
  password                = var.vast_password
  skip_ssl_verify         = var.vast_skip_ssl_verify
  version_validation_mode = var.vast_version_validation_mode
}
```

#### `main.tf` (Demonstrating Clean Code Usage)

```hcl
# ==============================================================================
# Clean Infrastructure Code (No repetitive provider tags required!)
# ==============================================================================

variable "tenant_name" {
  type    = string
  default = "default"
}

variable "vip_pool_name" {
  type    = string
  default = "my_dedicated_vip_pool"
}

variable "host_name" {
  type    = string
  default = "win-server-01"
}

variable "host_nqn" {
  type    = string
  default = "nqn.2014-08.org.nvmexpress:uuid:11111111-2222-3333-4444-555555555555"
}

# -------------------------------------------------------------------------
# Standard Resources (Implicitly use DEFAULT provider)
# -------------------------------------------------------------------------

# Uses default provider automatically
data "vastdata_tenant" "selected_tenant" {
  name = var.tenant_name
}

# Uses default provider automatically
data "vastdata_vip_pool" "selected_vip_pool" {
  name = var.vip_pool_name
}

# Uses default provider automatically
resource "vastdata_host" "default_cluster_host" {
  name = var.host_name
  nqn  = var.host_nqn
}

# -------------------------------------------------------------------------
# Special Case Resource (Explicitly uses ALIASED provider)
# -------------------------------------------------------------------------

# Explicitly targets GCP Cluster override
resource "vastdata_host" "gcp_cluster_host" {
  provider = vastdata.GCPCluster
  name     = "${var.host_name}-gcp"
  nqn      = var.host_nqn
}
```

---

### Implementation Instructions

**Option A: Drop-in Copy** Copy `provider.tf` directly into any new scratch folder alongside your test `main.tf` file.
  
**Option B: Dynamic Symbolic Link (Recommended for Fast Scratchpads)** Keep one master `provider.tf` in a central directory (e.g., `~/tf_global/provider.tf`) and dynamically link it into any test folder:

```bash
# 1. Load your credentials into your current terminal session
source ~/vast_env.sh

# 2. Navigate to your new scratch testing folder
cd ~/tf_tests/block_storage_test

# 3. Create a symbolic link to the master provider file
ln -s ~/tf_global/provider.tf ./provider.tf

# 4. Initialize and test immediately
terraform init
terraform plan
```