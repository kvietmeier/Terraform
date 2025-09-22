# NFS views
resource "vastdata_view" "nfs_views" {
  provider = vastdata.GCPCluster
  for_each = var.nfs_views_config

  name       = each.value.name
  path       = each.value.path
  protocols  = each.value.protocols
  policy_id  = vastdata_view_policy.nfs_basic_policy.id
  create_dir = each.value.create_dir
}

# S3 views
resource "vastdata_view" "s3_views" {
  provider = vastdata.GCPCluster
  for_each = local.s3_views

  name       = each.value.name
  path       = each.value.path
  protocols  = each.value.protocols
  policy_id  = each.value.policy_id
  create_dir = each.value.create_dir
}
