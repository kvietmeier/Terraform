###===================================================================================###
# 1. CORE DATA SOURCE LAYER
###===================================================================================###
# Targets the built-in admin role directly via its absolute system ID
data "vastdata_administrator_role" "platform_admin" {
  provider = vastdata.GCPCluster
  id       = 1
}

###===================================================================================###
# 2. LOCAL DYNAMIC VARIABLES
###===================================================================================###
locals {
  # Universal secure password meeting VAST complexity baseline (>=12 chars)
  common_student_password = "Chalc0pyr1te!"
}

###===================================================================================###
# 3. DIRECTORY POSIX GROUPS
###===================================================================================###
resource "vastdata_group" "groups" {
  provider = vastdata.GCPCluster
  for_each = var.groups

  name              = each.key
  gid               = each.value.gid
  local_provider_id = 1
}

###===================================================================================###
# 4. DIRECTORY POSIX USERS (Data Plane Isolation Profiles)
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

  local_provider_id = 1

  depends_on = [vastdata_group.groups]
}

###===================================================================================###
# 5. VMS SYSTEM MANAGERS (Validated Production Schema)
###===================================================================================###
resource "vastdata_administrator_manager" "student_admins" {
  provider = vastdata.GCPCluster
  for_each = var.users

  username                     = each.key
  password                     = local.common_student_password
  password_expiration_disabled = true
  
  first_name                   = "Lab"
  last_name                    = each.key

  # Securely maps your students to the resolved default cluster role ID attribute
  roles = [
    data.vastdata_administrator_role.platform_admin.id
  ]

  depends_on = [vastdata_user.users]
}