# Using environment variables for the Terraform Provider

Provider aliases allow you to manage multiple VAST clusters or distinct cluster configurations within the same Terraform configuration file. When combining aliases with environment variables, each aliased provider block can inherit global environment defaults or bind to cluster-specific variables.

## Overview of the Solution

Using a provider alias (`alias = "cluster_name"`) requires every resource or data source intended for that cluster to explicitly declare `provider = vastdata.cluster_name`.

_Development Steps:_

1. **Declare Aliased Provider Blocks:** Define distinct `provider "vastdata"` blocks using unique `alias` identifiers.
2. **Configure Environment Variables:** Map cluster-specific `TF_VAR_` shell variables so each provider alias can target a different cluster endpoint and credential set.
3. **Assign Providers to Resources:** Add the `provider = vastdata.<alias>` meta-argument to your resources and data lookups.

_Assumptions & Restrictions:_

- Native provider environment variables (`VASTDATA_HOST`, `VASTDATA_PORT`) apply globally to **all** provider blocks in a root module.
- To manage two different VAST clusters in the same Terraform folder, you must define separate input variables (e.g., `vast_cluster_a_host` and `vast_cluster_b_host`) fueled by distinct `TF_VAR_` shell variables.

### Environment Variable Configuration (`vast_env.sh`)

```bash
# ==============================================================================
# Environment Variables for Multiple VAST Clusters
# ==============================================================================

# Cluster A Credentials (GCP)
export TF_VAR_cluster_a_host="100.64.200.74"
export TF_VAR_cluster_a_username="admin"
export TF_VAR_cluster_a_password="PasswordClusterA!"

# Cluster B Credentials (On-Prem / AWS)
export TF_VAR_cluster_b_host="100.64.200.85"
export TF_VAR_cluster_b_username="admin"
export TF_VAR_cluster_b_password="PasswordClusterB!"

# Shared Security Settings
export TF_VAR_vast_skip_ssl_verify="true"
```

### Provider Configuration (`provider.tf`)

```hcl
# ==============================================================================
# Multi-Cluster Provider Setup with Aliases
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
# Variable Declarations (Populated by TF_VAR_ Shell Variables)
# -------------------------------------------------------------------------

variable "cluster_a_host" { type = string }
variable "cluster_a_username" { type = string }
variable "cluster_a_password" { 
  type      = string 
  sensitive = true 
}

variable "cluster_b_host" { type = string }
variable "cluster_b_username" { type = string }
variable "cluster_b_password" { 
  type      = string 
  sensitive = true 
}

variable "vast_skip_ssl_verify" { 
  type    = bool 
  default = true 
}

# -------------------------------------------------------------------------
# Aliased Provider Blocks
# -------------------------------------------------------------------------

# Primary Cluster (Alias: GCPCluster)
provider "vastdata" {
  alias           = "GCPCluster"
  host            = var.cluster_a_host
  username        = var.cluster_a_username
  password        = var.cluster_a_password
  skip_ssl_verify = var.vast_skip_ssl_verify
}

# Secondary Cluster (Alias: OnPremCluster)
provider "vastdata" {
  alias           = "OnPremCluster"
  host            = var.cluster_b_host
  username        = var.cluster_b_username
  password        = var.cluster_b_password
  skip_ssl_verify = var.vast_skip_ssl_verify
}
```

**Example Usage (`main.tf`)**

```hcl
# Resource targeting Cluster A (GCP)
resource "vastdata_host" "gcp_host" {
  provider = vastdata.GCPCluster
  name     = "win-server-gcp"
  nqn      = "nqn.2014-08.org.nvmexpress:uuid:11111111-1111-1111-1111-111111111111"
}

# Resource targeting Cluster B (On-Prem)
resource "vastdata_host" "onprem_host" {
  provider = vastdata.OnPremCluster
  name     = "win-server-onprem"
  nqn      = "nqn.2014-08.org.nvmexpress:uuid:22222222-2222-2222-2222-222222222222"
}
```

### Implementation Instructions

1. **Load Environment Variables:** Run `source vast_env.sh` in your terminal to export all connection strings.
2. **Assign Aliases:** Attach `provider = vastdata.<alias_name>` inside every resource or data source block you define.
3. **Deploy:** Execute `terraform init` and `terraform plan`. Terraform will open simultaneous API connections to both VAST clusters using their respective credentials.