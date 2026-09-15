###===================================================================================###
#  Module: vpc
#  Adapted from gcp/CoreInfra/vpcs/core (left untouched).
###===================================================================================###

locals {
  unique_regions = distinct([for subnet in var.subnets : subnet.region])
}

resource "google_compute_network" "custom_vpc" {
  provider                 = google-beta
  project                  = var.project_id
  name                     = var.vpc_name
  auto_create_subnetworks  = false
  enable_ula_internal_ipv6 = true
  routing_mode             = "GLOBAL"
}

resource "google_compute_global_address" "private_service_range" {
  name          = "private-service-access"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.custom_vpc.self_link
  address       = null
}

resource "google_project_service" "servicenetworking" {
  project = var.project_id
  service = "servicenetworking.googleapis.com"
}

resource "google_compute_subnetwork" "subnets" {
  for_each = { for subnet in var.subnets : subnet.name => subnet }

  name                     = each.value.name
  region                   = each.value.region
  ip_cidr_range            = each.value.ip_cidr_range
  network                  = google_compute_network.custom_vpc.id
  private_ip_google_access = true

  stack_type       = can(regex("ipv6$", each.value.name)) ? "IPV4_IPV6" : "IPV4_ONLY"
  ipv6_access_type = can(regex("ipv6$", each.value.name)) ? "INTERNAL" : null

  dynamic "secondary_ip_range" {
    for_each = try(
      [for r in each.value.secondary_ip_ranges : r if r != null],
      []
    )
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }
}

resource "google_compute_router" "routers" {
  for_each = { for region in local.unique_regions : region => region if contains(var.nat_enabled_regions, region) }
  name     = "router-${each.key}"
  network  = google_compute_network.custom_vpc.id
  region   = each.key
}

resource "google_compute_router_nat" "nats" {
  for_each                           = google_compute_router.routers
  name                               = "nat-${each.key}"
  router                             = each.value.name
  region                             = each.key
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  depends_on = [google_compute_router.routers]

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.custom_vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_service_range.name]

  depends_on = [google_project_service.servicenetworking]
}
