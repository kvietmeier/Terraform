### VAST Data – Terraform Automation for Demo/POC Deployments

> ⚠️ **Note:** This setup is not intended for production use. It includes default credentials, wide-open access ranges, and optional TLS/AD security disabled for simplified testing. Always review and harden configurations before applying to live environments.


---
#### Docs

* [VAST Data GitHub](https://github.com/vast-data)
* [Terraform Provider (GitHub)](https://github.com/vast-data/terraform-provider-vastdata)
* [Terraform Provider (Registry)](https://registry.terraform.io/providers/vast-data/vastdata/latest/docs)

---

### Testing basic authentication

For a quick test of authentication use the config in `simple_query`, it validates credentials and returns some basic metadata.

*You can also use this set of HCL/tf files as a starting point templatee to build more complex configurations*

Use like this - 
```shell
terraform apply -var-file="sq.var.tfvars" -auto-approve
```

You will get output like this if everything is working:
```shell
karlv@devops01:~/Terraform/vastdata/simple_query$ terraform apply 
data.vastdata_tenant.default: Reading...
data.vastdata_tenant.default: Read complete after 0s [name=default]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

cluster_description = "Demo cluster for PoC and testing"
cluster_name = "vast-demo-cluster"
cluster_region = "us-central1"
cluster_tags = tomap({
  "environment" = "dev"
  "project" = "vast-poc"
})
tenant_id = 1
```

---

### Setting up a fully functioning cluster from scratch

**For a complete example of setting up a cluster see (cluster_config):**

* VAST provider setup
* VIP Pool definitions for protocol and replication roles
* NFS and S3 view policies and exports
* DNS service configuration
* Active Directory integration options
* POSIX-style tenants, users, and group definitions

**Features**

* Modular and reusable design for rapid iteration
* Clear separation of configuration (`.tfvars`), logic (`main.tf`), and variables
* Supports multi-protocol (NFS/S3) configurations
* Uses dynamic constructs (e.g., `maps`, `count`, `for_each`) for scalability
* Compatible with VAST provider v1.6.8+


---

### Misc Notes

#### Example: Use existing VIP Pool for resources like Views


- Get the VIP Pool metadata - you need the tenantID that owns the Pool and the PoolID.

  ``` hcl
  data "vastdata_vip_pool" "protocolsVIP" {
      provider = vastdata.GCPCluster
      name     = "protocolsPool"
  }
  ```

- Use the VIP Pool - you need the tenantID that owns the Pool and the PoolID.

  ```hcl
  # Need a View Policy
  resource "vastdata_view_policy" "ViewPolicy01" {
    provider      = vastdata.GCPCluster
    name          = "ViewPolicy01"
    vip_pools     = [data.vastdata_vip_pool.protocolsVIP.id]
    tenant_id     = data.vastdata_vip_pool.protocolsVIP.tenant_id
    flavor        = "NFS"
    nfs_no_squash = [ "10.111.1.28", "10.111.1.26", "10.111.1.27" ] # Should be a list() var!
  }

  # Create the View
  resource "vastdata_view" "elbencho_view" {
    provider   = vastdata.GCPCluster
    path       = "/vast/share01"
    policy_id  = vastdata_view_policy.ViewPolicy01.id
    create_dir = "true"
    protocols  = ["NFS", "NFS4"]  # Should be a list() var!
  }
  ```

#### This is the VIP Pool object metadata available:

 - *VIP Poool ID:*

  ```hcl
  output "protocols_vip_pool_id" {
    value = data.vastdata_vip_pool.protocolsVIP.id
    description = "The ID of the protocols VIP pool."
  }
  ```

- *VIP Pool Name:*

  ```hcl
  output "protocols_vip_pool_name" {
    value = data.vastdata_vip_pool.protocolsVIP.name
    description = "The name of the protocols VIP pool."
  }
  ```

- *Tenant ID that owns the VIP Pool*

  ```hcl
  output "protocols_vip_pool_tenant_id" {
    value = data.vastdata_vip_pool.protocolsVIP.tenant_id
    description = "The tenant ID associated with the protocols VIP pool."
  }
  ```

- *Cluster Name where the VIP Pool lives:*

  ```hcl
  output "protocols_vip_pool_cluster" {
    value = data.vastdata_vip_pool.protocolsVIP.cluster
    description = "The cluster associated with the protocols VIP pool."
  }
  ```

- *Output:*

  ```hcl
  Outputs:

  protocols_vip_pool_cluster = "vastoncloud-gcp02"
  protocols_vip_pool_id = 3
  protocols_vip_pool_name = "protocolsPool"
  protocols_vip_pool_tenant_id = 1
  ```

---

#### Author/s

* **Karl Vietmeier**

#### License

This project is licensed under the Apache License - see the [LICENSE.md](../LICENSE.md) file for details

#### Acknowledgments

* None so far other than the many good examples out there.
