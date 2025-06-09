### Core GCP Infrastructutre Folders

This is fully functional production code to maintain core services and VMs.

* Infrastructure created/maintained

  ```shell
  C:.
  ├───firewalls
  │   ├───gcp_defaults
  │   ├───my_rules
  │   ├───open_ports
  │   └───wide_open
  │
  ├───nat_gw
  │
  ├───vms
  │   ├───ad_server
  │   └───linux_vm
  │ 
  └───vpcs
      ├───core
      └───testvpc01

```shell

#### Documentation Links

- [Terraform on GCP](https://cloud.google.com/docs/terraform)
- [HashiLearn - GCP](https://developer.hashicorp.com/terraform/tutorials/gcp-get-started)
- [Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Google Module Registry](https://registry.terraform.io/providers/hashicorp/google/latest)

#### Misc Notes

#### Author/s

- **Karl Vietmeier**

#### License

This project is licensed under the Apache License - see the [LICENSE.md](../../LICENSE.md) file for details
