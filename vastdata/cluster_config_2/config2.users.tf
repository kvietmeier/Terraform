###===================================================================================###
# VAST Data Cluster – Demo/POC Basic Setup
#
# Description:
# This Terraform file provisions user/tenant resources for a VAST Data cluster, intended
# for demo or proof-of-concept use cases. It defines the following:
#
# - Tenant creation from variable map (supports multiple tenants)
# - POSIX group and user creation with GID/UID mapping
# - Active Directory integration settings (without domain join)
# - Adds a key for S3 access
#
# Notes:
# - AD configuration uses bind credentials and supports LDAPS/TLS
# - Group/user relationships are mapped via supplementary and leading GIDs
# - VIP Pools and view policies referenced externally (not defined in this file)
# - `provider = vastdata.GCPCluster_jpn` must be declared elsewhere
#
###===================================================================================###

###===================================================================================###
# Groups
###===================================================================================###
resource "vastdata_group" "groups" {
  provider = vastdata.GCPCluster_jpn
  for_each = var.groups

  name = each.key
  gid  = each.value.gid
}

###===================================================================================###
# Users
###===================================================================================###
resource "vastdata_user" "users" {
  provider = vastdata.GCPCluster_jpn
  for_each = var.users

  name        = each.key
  uid         = each.value.uid
  leading_gid = vastdata_group.groups[each.value.leading_group_name].gid
  gids        = [for g in each.value.supplementary_groups : vastdata_group.groups[g].gid]

  allow_create_bucket = each.value.allow_create_bucket
  allow_delete_bucket = each.value.allow_delete_bucket
  s3_superuser        = each.value.s3_superuser

  depends_on = [vastdata_group.groups]
}

###===================================================================================###
# Tenants
###===================================================================================###
resource "vastdata_tenant" "tenants" {
  provider = vastdata.GCPCluster_jpn
  for_each = var.tenants
  name     = each.key

  client_ip_ranges = [
    for r in each.value.client_ip_ranges : [r.start_ip, r.end_ip]
  ]
}

###===================================================================================###
# S3 User Keys
###===================================================================================###
resource "vastdata_user_key" "s3keys" {
  provider      = vastdata.GCPCluster_jpn
  for_each      = toset(var.pgp_key_users)
  
  user_id       = vastdata_user.users[each.key].id
  enabled       = true
  pgp_public_key = file(var.s3pgpkey)
}
