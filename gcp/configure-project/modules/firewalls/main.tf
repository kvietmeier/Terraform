###===================================================================================###
#  Module: firewalls
#  Adapted from gcp/CoreInfra/firewalls/my_rules (left untouched).
#  network accepts VPC name or self_link.
###===================================================================================###

resource "google_compute_firewall" "vast_internal" {
  name        = "${var.vast_rules_name}-internal"
  network     = var.network
  description = "Self-referencing rule allowing ALL traffic between VAST cluster nodes"
  direction   = var.ingress_rule
  priority    = var.vast_priority

  allow {
    protocol = "all"
  }

  source_tags = ["voc-internal"]
  target_tags = ["voc-internal"]
}

resource "google_compute_firewall" "vast_client_access" {
  name        = "${var.vast_rules_name}-clients"
  network     = var.network
  description = "Allow tagged clients to mount storage and access APIs"
  direction   = var.ingress_rule
  priority    = var.vast_priority

  allow {
    protocol = "tcp"
    ports    = var.external_ingress_tcp
  }
  allow {
    protocol = "udp"
    ports    = var.external_ingress_udp
  }

  source_tags = ["voc-clients"]
  target_tags = ["voc-internal"]
}

resource "google_compute_firewall" "vast_replication" {
  name        = "${var.vast_rules_name}-replication"
  network     = var.network
  description = "Allow VAST replication traffic from designated peers"
  direction   = var.ingress_rule
  priority    = var.vast_priority

  allow {
    protocol = "tcp"
    ports    = ["49001", "49002"]
  }

  source_tags = ["voc-replication-peer", "voc-internal", "voc-clients"]
  target_tags = ["voc-internal"]
}

resource "google_compute_firewall" "vast_gcp_services" {
  name        = "${var.vast_rules_name}-gcp-services"
  network     = var.network
  description = "Allow GCP Health Checks and IAP to access VAST"
  direction   = var.ingress_rule
  priority    = var.vast_priority

  allow {
    protocol = "tcp"
    ports    = var.external_ingress_tcp
  }
  allow {
    protocol = "icmp"
  }

  source_ranges = var.gcp_service_cidrs
  target_tags   = ["voc-internal"]
}

resource "google_compute_firewall" "vast_external_ingress" {
  name        = "${var.vast_rules_name}-external"
  network     = var.network
  description = "Allow distant systems and on-prem networks to mount storage and access APIs"
  direction   = var.ingress_rule
  priority    = var.vast_priority

  allow {
    protocol = "tcp"
    ports    = var.external_ingress_tcp
  }
  allow {
    protocol = "udp"
    ports    = var.external_ingress_udp
  }
  allow {
    protocol = "icmp"
  }

  source_ranges = var.external_ingress
  target_tags   = ["voc-internal"]
}

resource "google_compute_firewall" "spark_rules" {
  name        = "spark-cluster-rules"
  network     = var.network
  description = "Spark Cluster rules - Internal self-referencing for Spark components"
  direction   = var.ingress_rule
  priority    = var.vast_priority

  allow {
    protocol = "tcp"
    ports    = concat(var.spark_tcp, var.spark_vast_tcp)
  }

  source_tags = ["spark-node", "voc-internal"]
  target_tags = ["spark-node"]
}

resource "google_compute_firewall" "default_services_rules" {
  name        = var.myrules_name
  network     = var.network
  description = var.description
  priority    = var.svcs_priority
  direction   = var.ingress_rule

  allow {
    protocol = "tcp"
    ports    = var.tcp_ports
  }

  allow {
    protocol = "udp"
    ports    = var.udp_ports
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = var.ingress_filter
  target_tags   = ["standard-services"]
}

resource "google_compute_firewall" "addc_rules" {
  name        = var.addc_name
  network     = var.network
  description = "Active Directory Domain Controller replication and client access"
  direction   = var.ingress_rule
  priority    = var.addc_priority

  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = var.addc_tcp_ports
  }
  allow {
    protocol = "udp"
    ports    = var.addc_udp_ports
  }

  source_ranges = var.ingress_filter
  source_tags   = ["ad-domaincontroller"]
  target_tags   = ["ad-domaincontroller"]
}

resource "google_compute_firewall" "deny_public_ingress" {
  count = var.enable_deny_public_ingress ? 1 : 0

  name        = "deny-public-ingress"
  network     = var.network
  description = "Deny incoming ICMP, SSH, RDP, and SMB traffic from public IPs"
  direction   = "INGRESS"
  priority    = 1000

  deny {
    protocol = "icmp"
  }

  deny {
    protocol = "tcp"
    ports    = ["22", "3389", "445"]
  }

  deny {
    protocol = "udp"
    ports    = ["445"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["no-public-access"]
  disabled      = false
}
