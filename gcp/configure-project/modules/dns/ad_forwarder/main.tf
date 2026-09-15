###===================================================================================###
#  Module: dns/ad_forwarder
#  Adapted from gcp/CoreInfra/DNS/AD-Forwarder
###===================================================================================###

resource "google_dns_managed_zone" "dns_forwarder" {
  name        = var.name
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

  forwarding_config {
    target_name_servers {
      ipv4_address = var.fw_target
    }
  }
}
