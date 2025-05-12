# Custom VPC Infrastructure with NAT Gateways and Cloud Routers

This Terraform module provisions a custom Virtual Private Cloud (VPC) in Google Cloud Platform (GCP) with the following components:

- Custom VPC with manual subnet creation
- Subnets (with support for secondary IP ranges and IPv6)
- Private Service Access for services like Cloud SQL and Memorystore
- Cloud Routers and Cloud NAT for internet access from private subnets
- Service Networking API enablement and peering

---

### Subnet Configuration

Dynamically creates subnets from var.subnets.
Supports:

- private_ip_google_access = true
- Optional secondary IP ranges
- Optional dual-stack (IPv4/IPv6) based on name matching

---

**Author:** Karl Vietmeier  
**Purpose:** Configure custom VPC infrastructure with support for NAT Gateways, Cloud Routers, and Service Networking.

---

## 🚀 Usage

Run the following Terraform commands with your custom variable file:

```bash
terraform plan -var-file=".\fw.terraform.tfvars"
terraform apply --auto-approve -var-file=".\fw.terraform.tfvars"
terraform destroy --auto-approve -var-file=".\fw.terraform.tfvars"
