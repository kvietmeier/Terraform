###===================================================================================###
#  File:        fw.terraform.tfvars
#  Author:      Karl Vietmeier
#
#  Purpose:     Define environment-specific values for firewall rule provisioning
#               in the 'karlv-corevpc' VPC using Terraform. This file contains
#               project, region, network, port lists, CIDR allowlists, and
#               scoped target tags used by `fw.main.tf`.
#
#  Notes:
#    - This file is excluded from version control (.gitignore).
#    - Update IP addresses, ports, and priorities as needed per environment.
#    - Supports multiple security zones: standard services, VAST, AD, ICMP control.
#
#  Used By:
#    - fw.main.tf            → Defines firewall resources
#    - fw.variables.tf       → Declares expected input variables
#
#  Usage:
#    terraform plan -var-file="fw.terraform.tfvars"
#    terraform apply --auto-approve -var-file="fw.terraform.tfvars"
#    terraform destroy --auto-approve -var-file="fw.terraform.tfvars"
#
###===================================================================================###


#--- Project & Provider Info
project_id  = "clouddev-itdesk124"
region      = "us-west2"
zone        = "us-west2-a"

#--- VPC Config
vpc_name    = "karlv-corevpc"
description = "Setup common ports and service FW rules for the core VPC"

#--- Firewall Directions & Naming
ingress_rule    = "INGRESS"
egress_rule     = "EGRESS"
myrules_name    = "core-firewall-rules"
addc_name       = "ad-rules"
vast_rules_name = "vast-rules"

#--- Rule Priorities
svcs_priority   = 500
vast_priority   = 500
addc_priority   = 501
egress_priority = 1000

#--- Baseline Ingress Filters (Trusted Core Ranges)
ingress_filter = [
  "10.0.0.0/8",
  "192.168.0.0/16"
]

#--- Standard Core Service Ports
tcp_ports = [
  "20", "21", "22", "45", "53", "80",
  "88", "119", "443", "445", "563", "5551",
  "3389", "5173", "8080"
]

udp_ports = [
  "53", "67", "68"
]

#--- Active Directory Ports
addc_tcp_ports = [
  "53", "88", "135", "137", "138",
  "139", "389", "445", "636",
  "49152-65535"
]

addc_udp_ports = [
  "53", "88", "123", "135",
  "137", "138", "389", "445"
]

###===================================================================================###
#--- VAST External/Client Access (Client-to-Cluster)
###===================================================================================###
external_ingress_tcp = [
  "22",     # SSH
  "53",     # DNS
  "80",     # S3 HTTP
  "111",    # rpcbind
  "443",    # S3 HTTPS
  "445",    # SMB
  "4420",   # NVMe-OF
  "5551",   # VMS Monitor
  "9092",   # Kafka
  "2049",   # NFS v3/v4.1+
  "20048",  # NFS mount
  "20049",  # NFS/RDMA
  "20106",  # NSM status
  "20107",  # NLM lockmgr
  "20108",  # NFS rquotad
  "49001",  # Replication
  "49002"   # Replication
]

external_ingress_udp = [
  "53",     # DNS
  "632",    # rpcbind UDP
  "2049",   # NFS v3/v4.1+
  "20048",  # NFS mount
  "20106",  # NSM status
  "20107",  # NLM lockmgr
  "20108"   # NFS rquotad
]

#--- Spark Component Ports
spark_tcp = [
  "8081", "8481", "8080", "8480", "6066", "7077", "18080", 
  "18480", "4040", "4440", "15002", "4041", "4441", "10000", "10001"
]

spark_vast_tcp = [
  "9293", "9493", "9292", "9492", "6066", "2424", "18080", 
  "18480", "4040", "4440", "15002", "4041", "4441", "10000", "10001"
]

#--- Static GCP Infrastructure Service Ranges
gcp_service_cidrs = [
  "35.191.0.0/16",    # GCP Load Balancer Health Checks
  "130.211.0.0/22",   # GCP Load Balancer Health Checks
  "199.36.153.4/30",  # Private Google Access
  "199.36.153.8/30",  # Private Google Access
  "35.235.240.0/20",  # Identity-Aware Proxy (IAP) for Secure SSH/TCP
  "35.199.192.0/19"   # Cloud DNS Health Checks/Resolvers
]

#--- Trusted External Public IPs or Untagged Remote Networks
external_ingress = [
  "47.144.97.34/32",
  "10.202.81.0/25",     
  "10.202.85.0/25",
  "172.69.0.0/24"
]