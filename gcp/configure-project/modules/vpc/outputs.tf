output "network_name" {
  description = "VPC network name"
  value       = google_compute_network.custom_vpc.name
}

output "network_id" {
  description = "VPC network ID"
  value       = google_compute_network.custom_vpc.id
}

output "network_self_link" {
  description = "VPC network self_link"
  value       = google_compute_network.custom_vpc.self_link
}

output "subnet_ids" {
  description = "Map of subnet name => subnet ID"
  value       = { for k, s in google_compute_subnetwork.subnets : k => s.id }
}

output "subnet_self_links" {
  description = "Map of subnet name => subnet self_link"
  value       = { for k, s in google_compute_subnetwork.subnets : k => s.self_link }
}

output "subnet_cidrs" {
  description = "Map of subnet name => primary CIDR"
  value       = { for k, s in google_compute_subnetwork.subnets : k => s.ip_cidr_range }
}

output "nat_enabled_regions" {
  description = "Regions where Cloud NAT is enabled"
  value       = var.nat_enabled_regions
}

output "service_networking_connection" {
  description = "Peering connection to servicenetworking.googleapis.com"
  value       = google_service_networking_connection.private_vpc_connection.network
}
