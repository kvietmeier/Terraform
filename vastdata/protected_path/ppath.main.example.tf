############################################
# Providers for two Vast Data clusters
############################################


############################################
# Cluster A: VIP pool (PROTOCOLS), Tenant, View Policy, View
############################################

data "vastdata_tenant" "tenant_clusterA" {
  name = "default"
}


data "vastdata_tenant" "tenant_clusterB" {
  provider = vastdata.clusterB
  name     = "default"
}


data "vastdata_view_policy" "view_policy_clusterB" {
  provider = vastdata.clusterB
  name     = "default"
}

data "vastdata_view_policy" "view_policy_clusterA" {
  name = "default"
}

resource "vastdata_view" "view_custerA" {
  path       = "/source"
  policy_id  = data.vastdata_view_policy.view_policy_clusterA.id
  tenant_id  = data.vastdata_tenant.tenant_clusterA.id
  create_dir = true
}

resource "vastdata_view" "view_custerB" {
  provider   = vastdata.clusterB
  path       = vastdata_protected_path.ppath.target_exported_dir
  policy_id  = data.vastdata_view_policy.view_policy_clusterB.id
  tenant_id  = data.vastdata_tenant.tenant_clusterB.id
  create_dir = true
}

############################################
# Replication setup (A <-> B)
############################################
resource "vastdata_vip_pool" "replication_poolA" {
  name = "gateway"
  role = "REPLICATION"
  subnet_cidr = "24"
  ip_ranges = [
    ["20.0.0.1", "20.0.0.5"]

  ]
}

resource "vastdata_vip_pool" "replication_poolB" {
  provider = vastdata.clusterB
  name     = "gateway"
  role = "REPLICATION"
  subnet_cidr = "24"
  ip_ranges = [
    ["20.0.0.6", "20.0.0.10"]
  ]
}

resource "vastdata_replication_peer" "clusterA_clusterB_peer" {
  # Peer is created on clusterA
  name        = "clusterA-clusterB-peer"
  leading_vip = vastdata_vip_pool.replication_poolB.start_ip
  pool_id     = vastdata_vip_pool.replication_poolA.id
}


############################################
# Protection policy (Framework-style frames map)
############################################
resource "vastdata_protection_policy" "protection_policy" {
  name             = "protection-policy"
  clone_type       = "NATIVE_REPLICATION"
  indestructible   = false
  prefix           = "policy-1"
  target_object_id = vastdata_replication_peer.clusterA_clusterB_peer.id

  frames = [{
    every       = "10m"
    keep_local  = "2H"
    keep_remote = "2H"
  }]
}


############################################
# Protected path (cross-cluster)
############################################
resource "vastdata_protected_path" "ppath" {
  name                 = "protected-path"
  source_dir           = vastdata_view.view_custerA.path
  tenant_id            = vastdata_view.view_custerA.tenant_id
  target_exported_dir  = "/destination"
  protection_policy_id = vastdata_protection_policy.protection_policy.id
  remote_tenant_guid   = data.vastdata_tenant.tenant_clusterB.guid
  sync_interval        = 900
}



############################################
# PROTOCOLS vip pools
############################################

resource "vastdata_vip_pool" "protocols_poolA" {
  name = "vippool-1"
  role = "PROTOCOLS"
  subnet_cidr = "24"
  ip_ranges = [
    ["172.0.0.1", "172.0.0.5"]

  ]
}

resource "vastdata_vip_pool" "protocols_poolB" {
  provider = vastdata.clusterB
  name     = "vippool-1"
  role = "PROTOCOLS"
  subnet_cidr = "24"
  ip_ranges = [
    ["172.0.0.6", "172.0.0.10"]
  ]
}