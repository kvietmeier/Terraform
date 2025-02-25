### Setup VAST Data Clusters

Setting up VAST clusters with Terraform.

* [VAST Data GitHub](https://github.com/vast-data)
* [Terraform Provider](https://github.com/vast-data/terraform-provider-vastdata)

---

#### Notes

Example: Create a View using existing VIP Pool.

``` terraform
data "vastdata_vip_pool" "protocolsVIP" {
    name = "protocolsPool"
}

```

Output/Data available:

``` terraform

output "protocols_vip_pool_id" {
  value = data.vastdata_vip_pool.protocolsVIP.id
  description = "The ID of the protocols VIP pool."
}

output "protocols_vip_pool_name" {
  value = data.vastdata_vip_pool.protocolsVIP.name
  description = "The name of the protocols VIP pool."
}

output "protocols_vip_pool_tenant_id" {
  value = data.vastdata_vip_pool.protocolsVIP.tenant_id
  description = "The tenant ID associated with the protocols VIP pool."
}

output "protocols_vip_pool_cluster" {
  value = data.vastdata_vip_pool.protocolsVIP.cluster
  description = "The cluster associated with the protocols VIP pool."
}
```

---

#### Author/s

* **Karl Vietmeier**

#### License

This project is licensed under the Apache License - see the [LICENSE.md](LICENSE.md) file for details

#### Acknowledgments

* None so far other than the many good examples out there.
