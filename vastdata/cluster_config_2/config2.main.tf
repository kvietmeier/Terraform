###===================================================================================###
# VAST Data – Cluster Resource Deployment for Demo/POC
#
# Description:
# This Terraform `main.tf` file provisions core VAST Data resources on a Google Cloud
# cluster, designed for functional evaluation or proof-of-concept (POC) environments.
# It orchestrates key components required for NFS, SMB, and S3 data access.
#
# Provisioned Resources:
# - VIP Pools:
#     - `sharesPool` (role: PROTOCOLS) for NFS/SMB data services
#     - `s3Pool` (role: PROTOCOLS) for S3-compatible services
#     - `targetPool` (role: REPLICATION) for inter-cluster replication
# - View Policies:
#     - NFS default policy with permissions tied to `sharesPool`
#     - S3 default policy with permissions tied to `s3Pool`
# - Views:
#     - Dynamic NFS views generated via `count`
#     - Static S3 view with bucket configuration
# - Policy-based access controls and DNS configuration for protocol resolution
#
# Features:
# - Automatically computes VIP ranges based on cluster node count
# - Supports multi-protocol deployments (NFS + S3) via distinct pools
# - Centralized pool references through `locals` for simplified configuration
# - Ensures ordered resource creation using `depends_on` where necessary
#
# Notes:
# - `sharesPool` and `s3Pool` must both be defined in `var.vip_pools` (names must match)
# - View policies require NFS/SMB ACLs even for S3-only deployments
# - Provider configuration (`vastdata.GCPCluster_2`) must be declared outside this file
# - Input variables must align with module references and `.tfvars` inputs
###===================================================================================###


###===================================================================================###
# DNS Configuration
###===================================================================================###
resource "vastdata_dns" "protocol_dns" {
  provider      = vastdata.GCPCluster_2
  name          = var.dns_name
  vip           = var.dns_vip
  net_type      = var.port_type
  domain_suffix = var.dns_domain_suffix
  enabled       = var.dns_enabled
}

### Protocols VIP Pools
resource "vastdata_vip_pool" "protocols" {
  provider    = vastdata.GCPCluster_2
  for_each    = local.protocols_pools

  name        = each.value.name
  domain_name = each.value.dns_name
  role        = each.value.role
  subnet_cidr = each.value.subnet_cidr
  ip_ranges   = [[each.value.start_ip, each.value.end_ip]]

  depends_on  = [vastdata_dns.protocol_dns]
}

### Replication VIP Pools
resource "vastdata_vip_pool" "replication" {
  provider    = vastdata.GCPCluster_2
  for_each    = local.replication_pools

  name        = each.value.name
  role        = each.value.role
  subnet_cidr = each.value.subnet_cidr
  ip_ranges   = [[each.value.start_ip, each.value.end_ip]]
}


###===================================================================================###
# Active Directory – Original Working Setup
###===================================================================================###
/* resource "vastdata_active_directory" "gcp_ad1" {
  provider             = vastdata.GCPCluster_2
  machine_account_name = var.ou_name
  organizational_unit  = var.ad_ou
  use_auto_discovery   = var.use_ad      # true to discover AD via DNS, false to specify host_name
  binddn               = var.bind_dn
  bindpw               = var.bindpw
  use_ldaps            = var.ldap
  domain_name          = var.ad_domain
  method               = var.method
  query_groups_mode    = var.query_mode
  use_tls              = var.use_tls
}
 */