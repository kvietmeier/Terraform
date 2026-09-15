###===================================================================================###
#  Module: dns/private_zone
#  Adapted from gcp/CoreInfra/DNS/my_domains
###===================================================================================###

resource "google_dns_managed_zone" "zone" {
  name        = var.zone_name
  dns_name    = var.dns_name
  description = var.description
  visibility  = "private"
  project     = var.project_id

  private_visibility_config {
    dynamic "networks" {
      for_each = var.network_urls
      content {
        network_url = networks.value
      }
    }
  }
}

resource "google_dns_record_set" "a_records" {
  for_each = var.a_records

  name         = "${each.key}.${var.dns_name}"
  managed_zone = google_dns_managed_zone.zone.name
  type         = "A"
  ttl          = 300
  rrdatas      = each.value
  project      = var.project_id
}
