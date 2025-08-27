## Custom VPC Infrastructure with NAT Gateways and Cloud Routers

This Terraform module provisions a custom Virtual Private Cloud (VPC) in Google Cloud Platform (GCP) with the following components:

- A named custom VPC with manual subnet creation
- Subnets across multiple GCP regions
- Optional secondary IP ranges (e.g., for services like GKE or VAST)
- IPv6 dual-stack support (where enabled)
- Private Google access on all subnets
- Cloud Routers and Cloud NAT (in user-specified regions)
- VPC Peering for Private Service Access (used by Cloud SQL, Memorystore, etc.)

---

### Subnet Configuration

Dynamically creates subnets from var.subnets.
Supports:

- region: GCP region
- name: Subnet name
- private_ip_google_access: true/false
- ip_cidr_range: Primary IPv4 CIDR block
- ipv6_cidr_range (optional): IPv6 block (for dual-stack subnets)
- secondary_ip_ranges (optional): Additional named secondary CIDR blocks (e.g., for services)

### Requirements

- Terraform ≥ 1.4
- Google Cloud Provider ≥ 5.9
- **Google Beta Provider for ipv6 EULA**
- Enabled APIs: compute.googleapis.com, servicenetworking.googleapis.com

---
- [Reference](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network)
- [Reference](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork)
- [Reference](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router)
- [Reference](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat)
- [Reference](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_)
- [Reference](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network)

#  Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network
#  Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork
#  Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router
#  Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat
#  Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_ipv6_ula_allocation
#  Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address
#  Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_networking_connection
#  Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service
#


---

**Author:** Karl Vietmeier  

---

### Usage

Run the following Terraform commands with your custom variable file:

```bash
terraform plan -var-file=".\corevpc.terraform.tfvars"
terraform apply --auto-approve -var-file=".\corevpc.terraform.tfvars"
terraform destroy --auto-approve -var-file=".\corevpc.terraform.tfvars"
```
