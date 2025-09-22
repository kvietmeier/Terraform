resource "vastdata_view_policy" "nfs_basic_policy" {
  provider  = vastdata.GCPCluster
  name      = var.nfs_basic_policy_name
  flavor    = "MIXED_LAST_WINS"
  protocols = ["NFS"]
}

resource "vastdata_view_policy" "s3_basic_policy" {
  provider  = vastdata.GCPCluster
  name      = var.s3_basic_policy_name
  flavor    = "S3_NATIVE"
  protocols = ["S3"]
}
