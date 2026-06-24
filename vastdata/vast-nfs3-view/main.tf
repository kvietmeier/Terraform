terraform {
  required_providers {
    vastdata = {
      source  = "vast-data/vastdata"
      version = "~> 3.2"
    }
  }
}

provider "vastdata" {
  username                = var.vast_username
  password                = var.vast_password
  host                    = var.vast_host
  port                    = 443
  skip_ssl_verify         = true
  version_validation_mode = "warn"
}

resource "vastdata_view_policy" "nfs3_no_root_squash_policy" {
  name   = var.view_policy_name
  flavor = "NFS"

  # Allow read/write from all clients
  nfs_read_write = ["*"]

  # Disable root squash for all clients
  nfs_no_squash = ["*"]
}

resource "vastdata_view" "nfs3_view" {
  path       = var.view_path
  create_dir = true

  policy_id = vastdata_view_policy.nfs3_no_root_squash_policy.id

  # NFSv3 only
  protocols = ["NFS"]
}
