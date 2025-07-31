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
# - `provider = vastdata.GCPCluster` must be declared elsewhere
#
###===================================================================================###


###===================================================================================###
# Groups
###===================================================================================###
resource "vastdata_group" "groups" {
  provider = vastdata.GCPCluster
  for_each = var.groups

  name = each.key
  gid  = each.value.gid
}


###===================================================================================###
# Users
###===================================================================================###
resource "vastdata_user" "users" {
  provider = vastdata.GCPCluster
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
  provider = vastdata.GCPCluster
  for_each = var.tenants

  name = each.key

  dynamic "client_ip_ranges" {
    for_each = each.value.client_ip_ranges
    content {
      start_ip = client_ip_ranges.value.start_ip
      end_ip   = client_ip_ranges.value.end_ip
    }
  }

  vippool_ids = try(each.value.vippool_ids, null)
}


###===================================================================================###
# Add Actve Directory DC Information - doesn't join the domain
###===================================================================================###
resource "vastdata_active_directory2" "gcp_ad1" {
  provider             = vastdata.GCPCluster
  machine_account_name = var.ou_name
  organizational_unit  = var.ad_ou
  use_auto_discovery   = var.use_ad
  binddn               = var.bind_dn
  bindpw               = var.bindpw
  use_ldaps            = var.ldap
  domain_name          = var.ad_domain
  method               = var.method
  query_groups_mode    = var.query_mode
  use_tls              = var.use_tls
  #searchbase           = "dc=qa,dc=vastdata,dc=com"
  #urls                 = ["ldap://198.51.100.3"]
} 


/*
###===================================================================================###
#   User Keys
###===================================================================================###

 You can create the key and provide a PGP public key so that the secret will be encrypted 
 using this public key. The PGP public key must be provided in the ASCII armor format. The
 encrypted secret key returned by the cluster will be set to the `encrypted_secret_key` field.

 If you do not set the PGP public key during key creation, the returned secret key will 
 be set to the `secret_key` field. It is highly recommended to avoid using this option. 
 Otherwise, ensure that your Terraform backend is well secured.

*/
 
resource "vastdata_user_key" "s3key1" {
  provider       = vastdata.GCPCluster
  user_id        = vastdata_user.users["s3user1"].id
  enabled        = false
  pgp_public_key = file(var.s3pgpkey)
}

