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

output "ssh_command" {
  description = "SSH into the forwarder (IAP if no public IP)"
  value = var.assign_public_ip ? format(
    "ssh -i %s %s@%s",
    var.ssh_private_key_path,
    var.ssh_user,
    try(google_compute_instance.bind.network_interface[0].access_config[0].nat_ip, google_compute_instance.bind.network_interface[0].network_ip)
    ) : format(
    "gcloud compute ssh %s@%s --zone=%s --tunnel-through-iap --ssh-key-file=%s",
    var.ssh_user,
    google_compute_instance.bind.name,
    var.zone,
    var.ssh_private_key_path
  )
}

output "client_resolv_snippet" {
  description = "systemd-resolved drop-in for test clients (selective VAST domain routing)"
  value       = <<-EOT
    # /etc/systemd/resolved.conf.d/vast-forwarder.conf
    [Resolve]
    DNS=${google_compute_instance.bind.network_interface[0].network_ip}
    Domains=${join(" ", [for z in var.vast_zones : "~${z}"])}
  EOT
}

output "verify_commands" {
  description = "Quick dig checks from the BIND VM or a client"
  value = join("\n", concat(
    [for z in var.vast_zones : "dig @${google_compute_instance.bind.network_interface[0].network_ip} something.${z}"],
    ["dig @${google_compute_instance.bind.network_interface[0].network_ip} google.com"]
  ))
}
