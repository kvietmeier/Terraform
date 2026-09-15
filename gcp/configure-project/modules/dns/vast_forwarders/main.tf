###===================================================================================###
#  Module: dns/vast_forwarders
#  Adapted from gcp/CoreInfra/DNS/vast_forwarders
###===================================================================================###

resource "google_dns_managed_zone" "dns_forwarder" {
  for_each = var.forwarding_zones

  name        = each.key
  dns_name    = each.value.dns_name
  description = each.value.description
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

  forwarding_config {
    target_name_servers {
      ipv4_address    = each.value.vastcluser_dns
      forwarding_path = try(each.value.forwarding_path, var.forwarding_path)
    }
  }
}
