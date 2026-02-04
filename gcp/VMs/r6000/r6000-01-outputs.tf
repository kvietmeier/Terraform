###===================================================================================###
#  File:        outputs.tf
#  Created By:  Karl Vietmeier
#  Purpose:     Expose connection details for the NVIDIA Blackwell Workstation
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
###===================================================================================###

output "vm_name" {
  description = "The name of the created workstation"
  value       = google_compute_instance.r6000_workstation.name
}

output "private_ip" {
  description = "Internal Private IP (VPC)"
  value       = google_compute_instance.r6000_workstation.network_interface[0].network_ip
}

output "public_ip" {
  description = "External Public IP (Use this for SSH and WebRTC Streaming)"
  value       = google_compute_instance.r6000_workstation.network_interface[0].access_config[0].nat_ip
}

output "ssh_connection_string" {
  description = "Copy/Paste command to connect"
  value       = "ssh -i ${local.ssh_key_file} terraform@${google_compute_instance.r6000_workstation.network_interface[0].access_config[0].nat_ip}"
}

output "webrtc_stream_url" {
  description = "URL to view Isaac Sim (After Docker Launch)"
  value       = "http://${google_compute_instance.r6000_workstation.network_interface[0].access_config[0].nat_ip}:8211/streaming/webrtc-client/"
}