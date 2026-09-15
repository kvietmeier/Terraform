output "managed_zone_id" {
  value = google_dns_managed_zone.zone.id
}

output "name_servers" {
  value = google_dns_managed_zone.zone.name_servers
}

output "a_record_names" {
  value = [for record in google_dns_record_set.a_records : record.name]
}
