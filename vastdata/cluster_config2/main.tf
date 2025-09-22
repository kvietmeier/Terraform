###===================================================================================###
# DNS Configuration
###===================================================================================###

resource "vastdata_dns" "protocol_dns" {
  provider      = vastdata.GCPCluster
  name          = var.dns_name
  vip           = var.dns_vip
  net_type      = var.port_type
  domain_suffix = var.dns_domain_suffix
  enabled       = var.dns_enabled
}

### Protocols VIP Pools
resource "vastdata_vip_pool" "protocols" {
  provider = vastdata.GCPCluster
  for_each = local.protocols_pools

  name      = each.value.name
  role      = each.value.role
  subnet_cidr = each.value.subnet_cidr
  ip_ranges = [[each.value.start_ip, each.value.end_ip]]
}

### Replication VIP Pools
resource "vastdata_vip_pool" "replication" {
  provider    = vastdata.GCPCluster
  for_each    = local.replication_pools

  name        = each.value.name
  subnet_cidr = each.value.subnet_cidr
  ip_ranges   = [[each.value.start_ip, each.value.end_ip]]
}