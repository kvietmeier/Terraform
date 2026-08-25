# Using environment variables for the Terraform Provider

You can declare a default provider alongside an aliased provider. In Terraform, any `provider` block defined without an `alias` argument automatically becomes the **default provider** for that resource type.

When a default provider exists, any resource or data lookup that omits the `provider = ...` meta-argument automatically uses the default configuration. You only need to explicitly specify `provider = vastdata.GCPCluster` on resources that need to target the aliased cluster.

## Overview of the Solution

This pattern allows you to write standard Terraform code without typing `provider = ...` on every single resource, while preserving the ability to target an explicit aliased provider when necessary.

**Development Steps:**

1. **Define a Default Provider Block:** Create a `provider "vastdata" {}` block without an `alias`. It auto-reads `VASTDATA_HOST`, `VASTDATA_PORT`, and your `TF_VAR_` environment variables.
2. **Define an Aliased Provider Block (Optional):** Create a second `provider "vastdata"` block with `alias = "GCPCluster"` for explicit overrides or secondary endpoints.
3. **Write Resources Naturally:** Omit `provider = ...` on standard resources to use the default configuration.

**Assumptions & Restrictions:**

- You can only have **one** default (un-aliased) provider block per provider type (`vastdata`) in a workspace.
- All standard `vastdata_*` resources will automatically inherit the default provider credentials unless explicitly directed elsewhere.

### Code Implementation

#### `provider.tf`

```hcl
# ==============================================================================
# Dual Provider Setup: Default vs. Aliased
# ==============================================================================

terraform {
  required_providers {
    vastdata = {
      source  = "vast-data/vastdata"
      version = "3.2.2"
    }
  }
}

# Shared Variable Declarations (Populated by TF_VAR_ environment variables)
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

# -------------------------------------------------------------------------
# 1. DEFAULT PROVIDER (No alias attribute)
# Standard resources automatically use this block!
# -------------------------------------------------------------------------
provider "vastdata" {
  # Automatically reads VASTDATA_HOST, VASTDATA_PORT, VASTDATA_TENANT
  username        = var.vast_username
  password        = var.vast_password
  skip_ssl_verify = var.vast_skip_ssl_verify
}

# -------------------------------------------------------------------------
# 2. ALIASED PROVIDER (Explicit opt-in)
# Used ONLY when 'provider = vastdata.GCPCluster' is specified
# -------------------------------------------------------------------------
variable "gcp_host" {
  type    = string
  default = null
}

provider "vastdata" {
  alias           = "GCPCluster"
  host            = var.gcp_host
  username        = var.vast_username
  password        = var.vast_password
  skip_ssl_verify = var.vast_skip_ssl_verify
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

### Implementation Instructions

1. **Save Configuration:** Place `provider.tf` in your working directory alongside `main.tf`.
2. **Export Environment Variables:** Run your shell script (`source vast_env.sh`) to export `VASTDATA_HOST`, `TF_VAR_vast_username`, and `TF_VAR_vast_password`. 
3. **Execute Terraform:** Run `terraform init` and `terraform plan`. Standard resources will execute seamlessly against your default cluster credentials without needing any inline provider tags.