###===================================================================================###
# VAST Data Cluser basic setup for demo/POC
#
# Notes:
# --role: PROTOCOLS | REPLICATION | VAST_CATALOG
#
# This file defines:
# - VAST provider connection settings
# - Two VIP Pools:
#     - sharesPool (role: PROTOCOLS)
#     - targetPool (role: REPLICATION)
# - Shared network settings
# - NFS view policy configuration
# - DNS
###===================================================================================###


/* #Create a tenant with the name tenent01 with client_ip_ranges
resource "vastdata_tenant" "tenant1" {
  provider     = vastdata.GCPCluster
  name         = var.tenant1_name
}
*/

resource "vastdata_tenant" "tenants" {
  provider         = vastdata.GCPCluster
  for_each         = { for tenant in var.tenants : tenant.name => tenant }
  name             = each.value.name
  #client_ip_ranges = each.value.client_ip_ranges
  #vippool_ids      = each.value.vippool_ids
}

#Create a user named user1 with leading group & supplementary groups
# Create groups from the list
resource "vastdata_group" "groups" {
  provider         = vastdata.GCPCluster
  for_each = { for g in var.groups : g.name => g }

  name = each.value.name
  gid  = each.value.gid
}

# Create users from the list
resource "vastdata_user" "users" {
  provider         = vastdata.GCPCluster
  for_each = { for u in var.users : u.name => u }

  name        = each.value.name
  uid         = each.value.uid
  leading_gid = vastdata_group.groups[each.value.leading_group_name].gid
  gids        = [for g in each.value.supplementary_groups : vastdata_group.groups[g].gid]

  depends_on = [vastdata_group.groups]
}

resource "vastdata_active_directory2" "gcp_ad1" {
  provider             = vastdata.GCPCluster
  machine_account_name = var.ou_name
  organizational_unit  = var.ad_ou
  use_auto_discovery   = var.use_ad
  binddn               = var.bind_dn
  #searchbase           = "dc=qa,dc=vastdata,dc=com"
  bindpw               = var.bindpw
  use_ldaps            = var.ldap
  domain_name          = var.ad_domain
  method               = var.method
  query_groups_mode    = var.query_mode
  use_tls              = var.use_tls
  #urls                 = ["ldap://198.51.100.3"]

}