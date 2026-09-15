output "firewall_names" {
  description = "Names of created firewall rules"
  value = compact(concat(
    [
      google_compute_firewall.vast_internal.name,
      google_compute_firewall.vast_client_access.name,
      google_compute_firewall.vast_replication.name,
      google_compute_firewall.vast_gcp_services.name,
      google_compute_firewall.vast_external_ingress.name,
      google_compute_firewall.spark_rules.name,
      google_compute_firewall.default_services_rules.name,
      google_compute_firewall.addc_rules.name,
    ],
    var.enable_deny_public_ingress ? [google_compute_firewall.deny_public_ingress[0].name] : []
  ))
}
