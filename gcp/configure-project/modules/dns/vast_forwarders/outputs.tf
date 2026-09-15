output "forwarding_zone_names" {
  description = "Map of zone resource name => DNS name"
  value = {
    for k, v in google_dns_managed_zone.dns_forwarder : k => v.dns_name
  }
}
