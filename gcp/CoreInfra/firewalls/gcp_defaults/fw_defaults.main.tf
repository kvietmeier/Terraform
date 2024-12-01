###===================================================================================###
#
#  File:  fw_defaults.main.tf
#  Created By: Karl Vietmeier
#
#  Purpose:  Create default GCP Firewall rules
# 
#  Files in Module:
#    main.tf
#    variables.tf
#    variables.tfvars
#
###===================================================================================###

/* 
  
Usage:
terraform plan -var-file=".\fw_defaults.tfvars"
terraform apply --auto-approve -var-file=".\fw_defaults.tfvars"
terraform destroy --auto-approve -var-file=".\fw_defaults.tfvars"

*/

###===================================================================================###
#     Start creating infrastructure resources
###===================================================================================###

resource "google_compute_firewall" "default_allow_internal" {
  name    = "default-allow-internal"
  network = "default"

  direction = "INGRESS"
  priority  = 65534

  source_ranges = ["10.0.0.0/8", "192.168.0.0/16", "172.16.0.0/12"]

  allow {
    protocol = "all"
  }
}

resource "google_compute_firewall" "default_allow_ssh" {
  name    = "default-allow-ssh"
  network = "default"

  direction = "INGRESS"
  priority  = 65534

  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_firewall" "default_allow_rdp" {
  name    = "default-allow-rdp"
  network = "default"

  direction = "INGRESS"
  priority  = 65534

  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }
}

resource "google_compute_firewall" "default_allow_icmp" {
  name    = "default-allow-icmp"
  network = "default"

  direction = "INGRESS"
  priority  = 65534

  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "icmp"
  }
}
