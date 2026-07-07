###===================================================================================###
#  File:        fw.main.tf
#  Author:      Karl Vietmeier
#
#  Purpose:     Define and apply custom firewall rules for the 'karlv-corevpc' VPC.
#               Uses highly secure network tags and self-referencing loops for VAST 
#               infrastructure, Spark, standard management services, and Active Directory.
#
#  Usage:
#    terraform plan 
#    terraform apply --auto-approve 
#    terraform destroy --auto-approve 
#
#  Structure:
#    - VAST Application Rules (Internal All-Pass, Segmented Client/External Access)
#    - Spark on VAST Component Interconnects
#    - Standard service management baseline rules (TCP, UDP, ICMP)
#    - Active Directory Domain Support & Controller Sync Loops
#
###===================================================================================###

###===================================================================================###
#     Start creating infrastructure resources
###===================================================================================##


###===================================================================================###
#     VAST Cluster Firewall Rules
###===================================================================================###

# 1. VAST Internal Cluster (Self-Referencing - ALL Traffic)
resource "google_compute_firewall" "vast_internal" {
  name        = "${var.vast_rules_name}-internal"
  network     = var.vpc_name              
  description = "Self-referencing rule allowing ALL traffic between VAST cluster nodes"
  direction   = var.ingress_rule
  priority    = var.vast_priority

  # Allow all protocols internally for the cluster (BKM)
  allow {
    protocol = "all"
  }

  source_tags = ["voc-internal"]
  target_tags = ["voc-internal"]   
}

# 2. VAST Client Access (Tagged Clients)
resource "google_compute_firewall" "vast_client_access" {
  name        = "${var.vast_rules_name}-clients"
  network     = var.vpc_name              
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

# 3. VAST Replication
resource "google_compute_firewall" "vast_replication" {
  name        = "${var.vast_rules_name}-replication"
  network     = var.vpc_name              
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

# 4. VAST GCP Services (Health Checks, IAP, etc.)
resource "google_compute_firewall" "vast_gcp_services" {
  name        = "${var.vast_rules_name}-gcp-services"
  network     = var.vpc_name              
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

# 5. External Ingress - non-GCP sources (e.g., on-prem, remote offices) 
resource "google_compute_firewall" "vast_external_ingress" {
  name        = "${var.vast_rules_name}-external"
  network     = var.vpc_name              
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

###===================================================================================###
#     Spark on VAST Rules
###===================================================================================###

resource "google_compute_firewall" "spark_rules" {
  name        = "spark-cluster-rules"
  network     = var.vpc_name              
  description = "Spark Cluster rules - Internal self-referencing for Spark components"
  direction   = var.ingress_rule
  priority    = var.vast_priority

  allow {
    protocol = "tcp"
    ports    = concat(var.spark_tcp, var.spark_vast_tcp)
  }

  source_tags   = ["spark-node", "voc-internal"]
  target_tags   = ["spark-node"]   
}

###===================================================================================###
#     Standard Services Rule
###===================================================================================###

resource "google_compute_firewall" "default_services_rules" {
  name        = var.myrules_name
  network     = var.vpc_name              
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

###===================================================================================###
#     Active Directory Rules
###===================================================================================###

resource "google_compute_firewall" "addc_rules" {
  name        = var.addc_name
  network     = var.vpc_name              
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