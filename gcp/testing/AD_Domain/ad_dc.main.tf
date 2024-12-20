###===================================================================================###
#
#  File:  Template.tf
#  Created By: Karl Vietmeier
#
#  Terraform Module Code
#  Purpose:  
# 
#  Files in Module:
#    main.tf
#    variables.tf
#    variables.tfvars
#
###===================================================================================###


/* 
  
Usage:
terraform plan -var-file=".\multivm_map.tfvars"
terraform apply --auto-approve -var-file=".\multivm_map.tfvars"
terraform destroy --auto-approve -var-file=".\multivm_map.tfvars"

*/


###===================================================================================###
#     Start creating infrastructure resources
###===================================================================================###

/* 
resource "google_compute_network" "vpc" {
  name = var.vpc_name
  auto_create_subnetworks = false
}
*/

resource "google_compute_subnetwork" "domain_controllers" {
  name          = "domain-controllers"
  ip_cidr_range = var.subnet_range_domain_controllers
  network       = google_compute_network.vpc.id
  region        = var.region
  enable_private_ip_google_access = true
}

resource "google_compute_subnetwork" "resources" {
  name          = "resources"
  ip_cidr_range = var.subnet_range_resources
  network       = google_compute_network.vpc.id
  region        = var.region
  enable_private_ip_google_access = true
}

resource "google_compute_firewall" "allow_rdp_ingress_from_iap" {
  name    = "allow-rdp-ingress-from-iap"
  network = google_compute_network.vpc.id

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  source_ranges  = ["35.235.240.0/20"]
  direction      = "INGRESS"
  enable_logging = true
  priority       = 10000
}

resource "google_compute_firewall" "allow_dns_ingress_from_clouddns" {
  name    = "allow-dns-ingress-from-clouddns"
  network = google_compute_network.vpc.id

  allow {
    protocol = "tcp"
    ports    = ["53"]
  }

  allow {
    protocol = "udp"
    ports    = ["53"]
  }

  source_ranges = ["35.199.192.0/19"]
  target_tags   = ["ad-domaincontroller"]
  direction     = "INGRESS"
  enable_logging = true
  priority      = 10000
}

resource "google_compute_firewall" "allow_replication_between_addc" {
  name    = "allow-replication-between-addc"
  network = google_compute_network.vpc.id

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["53", "88", "135", "389", "445", "49152-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["53", "88", "123", "389", "445"]
  }

  source_tags   = ["ad-domaincontroller"]
  target_tags   = ["ad-domaincontroller"]
  direction     = "INGRESS"
  enable_logging = true
  priority      = 10000
}

resource "google_compute_firewall" "allow_ldaps_ingress_to_addc" {
  name    = "allow-ldaps-ingress-to-addc"
  network = google_compute_network.vpc.id

  allow {
    protocol = "tcp"
    ports    = ["636"]
  }

  source_ranges = [var.subnet_range_resources]
  target_tags   = ["ad-domaincontroller"]
  direction     = "INGRESS"
  enable_logging = true
  priority      = 10000
}

resource "google_compute_firewall" "deny_ingress_from_all" {
  name    = "deny-ingress-from-all"
  network = google_compute_network.vpc.id

  deny {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  deny {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  source_ranges = ["0.0.0.0/0"]
  direction     = "INGRESS"
  enable_logging = true
  priority      = 65000
}

resource "google_compute_instance" "dc_1" {
  name         = "dc-1"
  machine_type = "n2-standard-8"
  zone         = "us-central1-a"

  tags = ["ad-domaincontroller"]

  boot_disk {
    initialize_params {
      image = "projects/windows-cloud/global/images/family/windows-2022"
    }
  }

  network_interface {
    subnetwork         = google_compute_subnetwork.domain_controllers.id
    private_ip_address = "10.0.0.2" # Replace with the appropriate IP
  }

  metadata = {
    ActiveDirectoryDnsDomain           = "cloud.example.com"
    ActiveDirectoryNetbiosDomain       = "CLOUD"
    ActiveDirectoryFirstDc             = "dc-1"
    sysprep-specialize-script-ps1      = "Install-WindowsFeature AD-Domain-Services; Install-WindowsFeature DNS"
    disable-account-manager            = "true"
  }

  metadata_startup_script = file("dc-startup.ps1")

  service_account {
    email  = "service-account-email@project.iam.gserviceaccount.com" # Replace with actual service account email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  deletion_protection = true
}

resource "google_compute_instance" "dc_2" {
  name         = "dc-2"
  machine_type = "n2-standard-8"
  zone         = "us-central1-b"

  tags = ["ad-domaincontroller"]

  boot_disk {
    initialize_params {
      image = "projects/windows-cloud/global/images/family/windows-2022"
    }
  }

  network_interface {
    subnetwork         = google_compute_subnetwork.domain_controllers.id
    private_ip_address = "10.0.0.3" # Replace with the appropriate IP
  }

  metadata = {
    ActiveDirectoryDnsDomain           = "cloud.example.com"
    ActiveDirectoryNetbiosDomain       = "CLOUD"
    ActiveDirectoryFirstDc             = "dc-1"
    sysprep-specialize-script-ps1      = "Install-WindowsFeature AD-Domain-Services; Install-WindowsFeature DNS"
    disable-account-manager            = "true"
  }

  metadata_startup_script = file("dc-startup.ps1")

  service_account {
    email  = "service-account-email@project.iam.gserviceaccount.com" # Replace with actual service account email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  deletion_protection = true
}
