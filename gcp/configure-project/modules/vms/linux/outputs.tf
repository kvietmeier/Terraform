output "instance_name" {
  value = google_compute_instance.vm_instance.name
}

output "instance_public_ip" {
  value = google_compute_address.vm_public_ip.address
}

output "instance_private_ip" {
  value = google_compute_address.vm_private_ip.address
}

output "zone" {
  value = google_compute_instance.vm_instance.zone
}
