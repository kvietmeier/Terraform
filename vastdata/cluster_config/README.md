### VAST Data Cluster Demo/POC Setup

This repository contains Terraform configurations to automate the setup of a basic VAST Data cluster environment for **demo or proof-of-concept (POC)** scenarios. The configuration includes:

- VAST provider and authentication
- VIP Pools for `PROTOCOLS` and `REPLICATION`
- Shared network settings
- NFS view policy and NFS views
- DNS configuration
- Basic multi-tenant setup with users and groups

---
### Elements Created

####  Provider Configuration
Establishes a connection to a VAST Data cluster using credentials and API endpoint info.

####  VIP Pools
Defines two VIP Pools:
- `sharesPool`: Assigned the `PROTOCOLS` role
- `targetPool`: Assigned the `REPLICATION` role

####  Network Settings
Common subnet CIDR and gateway values applied across VIP Pools.

####  Tenants, Groups, and Users
- Dynamically creates tenants from a list.
- Groups and users are provisioned with specified GIDs/UIDs and group relationships.

####  View Policy
Creates a VAST NFS view policy with:
- Authentication sources
- Read/write permissions
- VIP pool assignment

####  NFS Views
Provisioned using a loop, each with:
- Path prefix (e.g., `/nfs_share_1`, `/nfs_share_2`)
- Backed by the defined view policy
- Optionally creates a backing directory

####  DNS
Defines internal DNS mappings for the VAST cluster, using the `busab.org` domain suffix and specified VIP address.

---

###  Key Resources

| Resource               | Purpose                                 |
|------------------------|------------------------------------------|
| `vastdata_tenant`      | Creates tenants (multi-tenant support)   |
| `vastdata_group`       | Defines user groups                      |
| `vastdata_user`        | Creates users with group associations    |
| `vastdata_vip_pool`    | Configures VIP Pools for network access  |
| `vastdata_view_policy` | View policy for NFS and SMB access       |
| `vastdata_view`        | Provision of NFS views                   |
| `vastdata_dns`         | DNS setup for VAST domain resolution     |

---

#### Prerequisites
- Terraform installed
- VAST provider plugin installed
- Access to a VAST Data cluster (on GCP or other supported platforms)
