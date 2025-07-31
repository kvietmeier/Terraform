# Full End-to-End Configuration of a VAST Data Cluster from Scratch

This should always be a working version.


### VAST Data Cluster Demo/POC Setup

This repository contains Terraform configurations to automate the setup of a complete VAST Data cluster suitable for **demo or proof-of-concept (POC)** scenarios. The configuration includes:

- VAST Provider and authentication
- VIP Pools for `PROTOCOLS`, `REPLICATION`, and `VAST_CATALOG`
- NFS view policy and NFS views
- S3 view policy and NFS views
- S3 User policies
- DNS configuration
- Basic multi-tenant setup with users and groups
- Active Directory integration

---

### Prerequisites
- Terraform installed
- VAST provider plugin initialized
- Access to a VAST Data cluster (on GCP or other supported platforms)
- Accessible Active Directory DC
- DNS Forwarder or Delegation configured to point to the VAST DNS domain/s

### Elements Created

####  Provider Configuration
Establishes a connection to a VAST Data cluster using credentials and API endpoint info.

####  VIP Pools
Defines two VIP Pools:
- `sharesPool`: Assigned the `PROTOCOLS` role
- `targetPool`: Assigned the `REPLICATION` role

####  Tenants, Groups, and Users
- Dynamically creates tenants from a list.
- Groups and users are provisioned with specified GIDs/UIDs and group relationships.

####  View Policy
Creates a VAST NFS view policy with:
- Authentication sources
- Read/write permissions
- VIP pool assignment

####  S3 User Policies
- Sample configurations loaded from json files

####  NFS Views
Provisioned using a loop, each with:
- Path prefix (e.g., `/nfs_share_1`, `/nfs_share_2`)
- Backed by the defined view policy
- Optionally creates a backing directory

####  DNS
Defines a VAST DNS server for the VAST cluster, using the `busab.org` domain suffix and specified VIP address.

####  Active Directory
Configure Active Directory integration to join the `ginaz.org` domain.

---

### Examples:

The online documentation doesn't have very good examples of things like DNS and setting up S3 and the LLMs do not have correct information on the Provider. As I figure out how to configure them I will try to put some examples here with explantions.

#### DNS
It isn't immediately clear from the documentation that you need to configure it in 2 places to get a complete implementation.  
  
**Important Note**  
*The `domain_suffix` can only be used with VIP Pools assigned the `PROTOCOLS` role.*  
  
- In the DNS resource "*domain_suffix*" is the root domain of the FQDN or properly the "*domain name*":

  ```hcl
  resource "vastdata_dns" "protocol_dns" {
    provider      = vastdata.GCPCluster
    name          = var.dns_name
    vip           = var.dns_vip
    net_type      = var.port_type
    domain_suffix = var.dns_domain_suffix
    enabled       = var.dns_enabled
  }
  ```
- In the VIP Pool resource it can be confusing because the attribute you need to set is named incorrectly - it is called the "*domain_name*" when it is more correctly refered to as the "*short, or host name*". *Not sure it is required but just in case I added a dependency on DNS being setup first*:

  ```hcl
  resource "vastdata_vip_pool" "protocols" {
  provider     = vastdata.GCPCluster
  name         = var.vip1_name
  domain_name  = var.dns_shortname
  role         = var.role1
  subnet_cidr  = var.cidr
  gw_ip        = var.gw1
  ip_ranges {
        start_ip = var.vip1_startip
        end_ip   = var.vip1_endip
    }
    
  depends_on = [vastdata_dns.protocol_dns]
  }
  ```

---

###  Key Resources

| Resource                              | Purpose                                           |
|---------------------------------------|---------------------------------------------------|
| `vastdata_tenant`                     | Creates tenants (multi-tenant support)            |
| `vastdata_group`                      | Defines user groups                               |
| `vastdata_user`                       | Creates users with group associations             |
| `vastdata_vip_pool`                   | Configures VIP Pools for network access           |
| `vastdata_view_policy`                | View policy for NFS and SMB access                |
| `vastdata_view`                       | Provision of NFS views                            |
| `vastdata_dns`                        | DNS setup for VAST domain resolution              |
| `vastdata_active_directory2`          | Configure Active Directory Domain integration     |
| `vastdata_s3_policy`                  | Define an S3 User Policy     |
|---------------------------------------|---------------------------------------------------|

---

#### Author

* **Karl Vietmeier**

#### License

This project is licensed under the Apache License - see the [LICENSE.md](../../LICENSE.md) file for details

#### Acknowledgments

* Josh Wentzel for getting me started down this path.