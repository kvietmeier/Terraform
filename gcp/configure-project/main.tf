###===================================================================================###
#  configure-project — consolidated GCP CoreInfra root
#
#  Creates hub VPC first, then optionally firewalls, DNS, VPN, VMs, and IAP.
#  Original stacks under gcp/CoreInfra/ are intentionally unchanged.
###===================================================================================###

module "vpc" {
  source = "./modules/vpc"

  project_id          = var.project_id
  vpc_name            = var.vpc_name
  subnets             = var.subnets
  nat_enabled_regions = var.nat_enabled_regions
}

module "firewalls" {
  count  = var.enable_firewalls ? 1 : 0
  source = "./modules/firewalls"

  network                    = module.vpc.network_name
  description                = var.firewall.description
  myrules_name               = var.firewall.myrules_name
  addc_name                  = var.firewall.addc_name
  vast_rules_name            = var.firewall.vast_rules_name
  ingress_filter             = var.firewall.ingress_filter
  tcp_ports                  = var.firewall.tcp_ports
  udp_ports                  = var.firewall.udp_ports
  spark_tcp                  = var.firewall.spark_tcp
  spark_vast_tcp             = var.firewall.spark_vast_tcp
  addc_tcp_ports             = var.firewall.addc_tcp_ports
  addc_udp_ports             = var.firewall.addc_udp_ports
  external_ingress_tcp       = var.firewall.external_ingress_tcp
  external_ingress_udp       = var.firewall.external_ingress_udp
  gcp_service_cidrs          = var.firewall.gcp_service_cidrs
  external_ingress           = var.firewall.external_ingress
  enable_deny_public_ingress = try(var.firewall.enable_deny_public_ingress, true)

  depends_on = [module.vpc]
}

module "dns_private" {
  count  = var.enable_dns_private ? 1 : 0
  source = "./modules/dns/private_zone"

  project_id   = var.project_id
  zone_name    = var.dns_private.zone_name
  dns_name     = var.dns_private.dns_name
  description  = var.dns_private.description
  network_urls = local.network_urls
  a_records    = var.dns_private.a_records

  depends_on = [module.vpc]
}

module "dns_vast_forwarders" {
  count  = var.enable_dns_vast_forwarders && length(var.dns_vast_forwarders) > 0 ? 1 : 0
  source = "./modules/dns/vast_forwarders"

  project_id       = var.project_id
  network_urls     = local.network_urls
  forwarding_zones = var.dns_vast_forwarders

  depends_on = [module.vpc]
}

module "linux_vms" {
  for_each = var.enable_linux_vms ? var.linux_vms : {}
  source   = "./modules/vms/linux"

  project_id           = var.project_id
  region               = each.value.region
  zone                 = each.value.zone
  vm_name              = each.value.vm_name
  machine_type         = each.value.machine_type
  os_image             = each.value.os_image
  bootdisk_size        = each.value.bootdisk_size
  sa_email             = each.value.sa_email
  sa_scopes            = each.value.sa_scopes
  ssh_user             = each.value.ssh_user
  ssh_key_file         = each.value.ssh_key_file
  cloudinit_configfile = each.value.cloudinit_configfile
  vm_tags              = each.value.vm_tags
  subnet               = module.vpc.subnet_self_links[each.value.subnet_name]
  public_ip_name       = each.value.public_ip_name
  private_ip_name      = each.value.private_ip_name
  private_ip           = each.value.private_ip
  assign_public_ip     = each.value.assign_public_ip

  depends_on = [module.vpc, module.firewalls]
}

module "windows_vms" {
  for_each = var.enable_windows_vms ? var.windows_vms : {}
  source   = "./modules/vms/windows"

  project_id             = var.project_id
  region                 = each.value.region
  zone                   = each.value.zone
  vm_name                = each.value.vm_name
  machine_type           = each.value.machine_type
  os_image               = each.value.os_image
  bootdisk_size          = each.value.bootdisk_size
  sa_email               = each.value.sa_email
  sa_scopes              = each.value.sa_scopes
  windows_sysprep_script = each.value.windows_sysprep_script
  vm_tags                = each.value.vm_tags
  subnet                 = module.vpc.subnet_self_links[each.value.subnet_name]
  public_ip_name         = each.value.public_ip_name
  private_ip_name        = each.value.private_ip_name
  private_ip             = each.value.private_ip
  assign_public_ip       = each.value.assign_public_ip

  depends_on = [module.vpc, module.firewalls]
}

module "dns_ad_forwarder" {
  count  = var.enable_dns_ad_forwarder ? 1 : 0
  source = "./modules/dns/ad_forwarder"

  project_id   = var.project_id
  name         = var.dns_ad_forwarder.name
  dns_name     = var.dns_ad_forwarder.dns_name
  description  = var.dns_ad_forwarder.description
  network_urls = local.network_urls
  fw_target = coalesce(
    var.dns_ad_forwarder.fw_target,
    try(values(module.windows_vms)[0].private_ip, null)
  )

  depends_on = [module.vpc, module.windows_vms]
}

module "vpn_gw" {
  count  = var.enable_vpn ? 1 : 0
  source = "./modules/vpn_gw"

  region               = var.vpn.region
  network              = module.vpc.network_name
  ha_vpn_gw_name       = var.vpn.ha_vpn_gw_name
  router_name          = var.vpn.router_name
  external_gw_name     = var.vpn.external_gw_name
  gcp_asn              = var.vpn.gcp_asn
  tunnel_if0           = var.vpn.tunnel_if0
  tunnel_if1           = var.vpn.tunnel_if1
  interface0           = var.vpn.interface0
  interface1           = var.vpn.interface1
  gcp_apipa_bgp_a      = var.vpn.gcp_apipa_bgp_a
  gcp_apipa_bgp_b      = var.vpn.gcp_apipa_bgp_b
  bgp_peer_if0         = var.vpn.bgp_peer_if0
  bgp_peer_if1         = var.vpn.bgp_peer_if1
  priority             = var.vpn.priority
  shared_key           = var.vpn.shared_key
  azure_pubip0         = var.vpn.azure_pubip0
  azure_pubip1         = var.vpn.azure_pubip1
  azure_apipa_bgp_a    = var.vpn.azure_apipa_bgp_a
  azure_apipa_bgp_b    = var.vpn.azure_apipa_bgp_b
  azure_asn            = var.vpn.azure_asn
  advertised_ip_ranges = var.vpn.advertised_ip_ranges

  depends_on = [module.vpc]
}

module "iap" {
  count  = var.enable_iap ? 1 : 0
  source = "./modules/iap"

  project_id  = var.project_id
  user_emails = var.iap_user_emails
}
