###===================================================================================###
#
#  File:  bind.outputs.tf
#  Created By: Karl Vietmeier
#
###===================================================================================###

output "bind_private_ip" {
  description = "Private IP of the BIND forwarder — point clients here"
  value       = google_compute_instance.bind.network_interface[0].network_ip
}

output "bind_instance_name" {
  description = "GCE instance name"
  value       = google_compute_instance.bind.name
}

output "bind_zone" {
  description = "GCE zone"
  value       = google_compute_instance.bind.zone
}

output "vast_zones" {
  description = "Zones forwarded to VAST"
  value       = var.vast_zones
}

output "vast_dns_ips" {
  description = "VAST DNS target IPs"
  value       = var.vast_dns_ips
}

output "dns_firewall_name" {
  description = "Firewall rule name (if enable_dns_firewall)"
  value       = try(google_compute_firewall.bind_dns[0].name, null)
}

output "ssh_command" {
  description = "IAP SSH into the forwarder"
  value = format(
    "gcloud compute ssh %s@%s --zone=%s --project=%s --tunnel-through-iap",
    var.ssh_user,
    google_compute_instance.bind.name,
    var.zone,
    var.project_id
  )
}

output "stop_command" {
  value = format(
    "gcloud compute instances stop %s --zone=%s --project=%s",
    google_compute_instance.bind.name,
    var.zone,
    var.project_id
  )
}

output "start_command" {
  value = format(
    "gcloud compute instances start %s --zone=%s --project=%s",
    google_compute_instance.bind.name,
    var.zone,
    var.project_id
  )
}

output "client_resolv_snippet" {
  description = "systemd-resolved drop-in for test clients"
  value       = <<-EOT
    # /etc/systemd/resolved.conf.d/vast-forwarder.conf
    [Resolve]
    DNS=${google_compute_instance.bind.network_interface[0].network_ip}
    Domains=${join(" ", [for z in var.vast_zones : "~${z}"])}
  EOT
}

output "verify_commands" {
  description = "Checks on the BIND VM and from a client"
  value       = <<-EOT
    # on BIND VM
    sudo named-checkconf /etc/bind/named.conf
    sudo systemctl status bind9 || sudo systemctl status named
    dig @localhost google.com
    ${join("\n    ", [for z in var.vast_zones : "dig @localhost something.${z}"])}

    # from a client (labuser0N@client0N)
    ${join("\n    ", [for z in var.vast_zones : "dig @${google_compute_instance.bind.network_interface[0].network_ip} something.${z}"])}
    dig @${google_compute_instance.bind.network_interface[0].network_ip} google.com
  EOT
}
