### Using the VAST Data Provider

---
#### Docs

* [VAST Data GitHub](https://github.com/vast-data)
* [Terraform Provider (GitHub)](https://github.com/vast-data/terraform-provider-vastdata)
* [Terraform Provider (Registry)](https://registry.terraform.io/providers/vast-data/vastdata/latest/docs)

---

#### Configurations

setup1:  Using the VAST Data provider to setup a View with an existing VIP Pool.

```text
.
├── README.md
└── setup1
    ├── main.tf
    ├── provider.tf
    ├── terraform.tfvars
    └── variables.tf
```

---
#### Notes

Example: Use existing VIP Pool for resources like Views.

``` terraform
data "vastdata_vip_pool" "protocolsVIP" {
    name = "protocolsPool"
}
```

Use the VIP Pool - you need the tenantID that owns the Pool and the PoolID.

``` terraform
# Need a View Policy
resource "vastdata_view_policy" "ViewPolicy01" {
  name          = "ViewPolicy01"
  vip_pools     = [data.vastdata_vip_pool.protocolsVIP.id]
  tenant_id     = data.vastdata_vip_pool.protocolsVIP.tenant_id
  flavor        = "NFS"
  nfs_no_squash = [ "10.111.1.28", "10.111.1.26", "10.111.1.27" ]
}

# Create the View
resource "vastdata_view" "elbencho_view" {
  path       = "/vast/share01"
  policy_id  = vastdata_view_policy.ViewPolicy01.id
  create_dir = "true"
  protocols  = ["NFS", "NFS4"]
}

```

---

These are the object metada available:

*VIP Poool ID:*
``` terraform
output "protocols_vip_pool_id" {
  value = data.vastdata_vip_pool.protocolsVIP.id
  description = "The ID of the protocols VIP pool."
}
```

*VIP Pool Name:*
``` terraform
output "protocols_vip_pool_name" {
  value = data.vastdata_vip_pool.protocolsVIP.name
  description = "The name of the protocols VIP pool."
}
```

*Tenant ID that owns the VIP Pool*
``` terraform
output "protocols_vip_pool_tenant_id" {
  value = data.vastdata_vip_pool.protocolsVIP.tenant_id
  description = "The tenant ID associated with the protocols VIP pool."
}
```

*Cluster Name where the VIP Pool lives:*
``` terraform
output "protocols_vip_pool_cluster" {
  value = data.vastdata_vip_pool.protocolsVIP.cluster
  description = "The cluster associated with the protocols VIP pool."
}
```

Output - 
``` terraform
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
