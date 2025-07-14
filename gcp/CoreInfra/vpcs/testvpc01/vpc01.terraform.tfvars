###===================================================================================###
#
#  File:  tfvars file
#  Created By: Karl Vietmeier
#
#  Purpose:   Configure custom VPC with subnets, NAT GW, and Cloud Routers
# 
###===================================================================================###

# Project Info
project_id      = "clouddev-itdesk124"
region          = "us-west3"
zone            = "us-west3-a"

default_region = "us-west3"
vpc_name       = "karlv-testvpc01"

### Add subnets to the list and re-run apply
subnets = [
  { name = "subnet-hub-west1"          , region = "us-west1"        , ip_cidr_range = "121.20.0.0/20" },
  { name = "subnet-hub-west2"          , region = "us-west2"        , ip_cidr_range = "121.21.0.0/20" },
  { name = "subnet-hub-west3"          , region = "us-west3"        , ip_cidr_range = "121.22.0.0/20" },
  { name = "subnet-hub-west4"          , region = "us-west4"        , ip_cidr_range = "121.23.0.0/20" },
  { name = "subnet-hub-central1"       , region = "us-central1"     , ip_cidr_range = "121.24.0.0/20" },
  { name = "subnet-hub-south1"         , region = "us-south1"       , ip_cidr_range = "121.25.0.0/20" },
  { name = "subnet-hub-east1"          , region = "us-east1"        , ip_cidr_range = "121.26.0.0/20" },
  { name = "subnet-hub-east4"          , region = "us-east4"        , ip_cidr_range = "121.27.0.0/20" },
  { name = "subnet-hub-east5"          , region = "us-east5"        , ip_cidr_range = "121.28.0.0/20" },
  { name = "subnet-hub-europe-west1"   , region = "europe-west1"    , ip_cidr_range = "121.29.0.0/20" },
  { name = "subnet-hub-europe-west2"   , region = "europe-west2"    , ip_cidr_range = "121.30.0.0/20" },
  { name = "subnet-hub-europe-west3"   , region = "europe-west3"    , ip_cidr_range = "121.31.0.0/20" },
  { name = "subnet-hub-europe-west4"   , region = "europe-west4"    , ip_cidr_range = "121.32.0.0/20" },
  { name = "subnet-hub-europe-north1"  , region = "europe-north1"   , ip_cidr_range = "121.33.0.0/20" },
  { name = "subnet-hub-europe-north2"  , region = "europe-north2"   , ip_cidr_range = "121.34.0.0/20" },
  { name = "subnet-hub-europe-central2", region = "europe-central2" , ip_cidr_range = "121.35.0.0/20" },
  { name = "subnet-hub-europe-southwest1", region = "europe-southwest1", ip_cidr_range = "121.36.0.0/20" },
  { name = "subnet-hub-me-central1"    , region = "me-central1"     , ip_cidr_range = "121.37.0.0/20" },
  { name = "subnet-hub-me-central2"    , region = "me-central2"     , ip_cidr_range = "121.38.0.0/20" },
  { name = "subnet-hub-me-west1"       , region = "me-west1"        , ip_cidr_range = "121.39.0.0/20" },
  { name = "subnet-hub-asia-south1"    , region = "asia-south1"     , ip_cidr_range = "121.40.0.0/20" },
  { name = "subnet-hub-asia-south2"    , region = "asia-south2"     , ip_cidr_range = "121.41.0.0/20" },
  { name = "subnet-hub-asia-east1"     , region = "asia-east1"      , ip_cidr_range = "121.42.0.0/20" },
  { name = "subnet-hub-asia-east2"     , region = "asia-east2"      , ip_cidr_range = "121.43.0.0/20" }
]

### Regions with NAT GW
nat_enabled_regions = [
  "us-west1",
  "us-west2",
  "us-west3",
  "us-west4",
  "us-east1",
  "us-east5",
  "europe-west1",
  "europe-north1",
  "me-centra1",
  "asia-east1",
  "asia-south1"
  ]

ingress_filter = [
  "47.144.111.57",     # My ISP Address
  "35.191.0.0/16",     # GCP health checks
  "130.211.0.0/22",    # GCP health checks
  "192.168.0.0/16",    # Docker
  "172.16.0.0/12",     # Docker
  "10.0.0.0/8"         # Internal
]