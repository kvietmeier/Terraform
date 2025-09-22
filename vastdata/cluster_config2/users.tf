###===================================================================================###
# VAST Data – Users, Groups, Tenants, and S3 Keys
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
  name     = each.key

  client_ip_ranges = [
    for r in each.value.client_ip_ranges : [r.start_ip, r.end_ip]
  ]
}

###===================================================================================###
# S3 User Keys
###===================================================================================###
resource "vastdata_user_key" "s3keys" {
  provider      = vastdata.GCPCluster
  for_each      = toset(var.pgp_key_users)
  
  user_id       = vastdata_user.users[each.key].id
  enabled       = true
  pgp_public_key = file(var.s3pgpkey)
}
