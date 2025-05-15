# VAST Data Views and Policies Terraform Module

## Overview

This Terraform module automates the creation of VAST Data **view policies** and **NFS views** using an existing VIP pool on a VAST cluster.

- ✅ Uses provider alias for targeting a specific VAST cluster (e.g. GCP, On-Prem)
- ✅ Supports NFS and SMB protocols
- ✅ Leverages existing VIP Pools via a data source
- ✅ Fully parameterized via `terraform.tfvars`

---

## Prerequisites

- Terraform >= 1.3
- VAST Data Terraform Provider >= 1.6.0
- Access credentials to the VAST cluster
- An existing VIP Pool (e.g., `protocolsPool`)

---

## Files

| File                     | Purpose                                      |
|--------------------------|----------------------------------------------|
| `main.tf`                | Core logic to create view policy and views   |
| `provider.tf`            | VAST provider setup with alias support       |
| `variables.tf`           | Input variables and defaults                 |
| `terraform.tfvars`       | Example values for running the module        |
| `outputs.tf`             | (Optional) Outputs from the module           |

---

## Usage

### Step 1: Customize Inputs

Edit the `terraform.tfvars` with your desired configuration:
```hcl
vip_pool_existing       = "protocolsPool"
policy_name             = "vpolicy-nfs"
view_policy_flavor      = "nfs_only"
use_auth_provider       = false
access_flavor           = "rw"
nfs_no_squash           = ["0.0.0.0/0"]
nfs_read_write          = ["*"]
num_views               = 3
path_name               = "vastview"
