output "zone_id" {
  value = google_dns_managed_zone.dns_forwarder.id
}

output "zone_name" {
  value = google_dns_managed_zone.dns_forwarder.name
}
