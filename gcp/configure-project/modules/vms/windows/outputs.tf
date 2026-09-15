output "instance_name" {
  value = google_compute_instance.vm_instance.name
}

output "public_ip" {
  value = google_compute_address.vm_public_ip.address
}

output "private_ip" {
  value = google_compute_instance.vm_instance.network_interface[0].network_ip
}

output "zone" {
  value = google_compute_instance.vm_instance.zone
}
