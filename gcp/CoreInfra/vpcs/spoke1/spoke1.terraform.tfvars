##========================================================================================###
##
##  Values for VPC Spoke1
##
##========================================================================================###

## Project Info
project_id      = "clouddev-itdesk124"
region          = "us-west3"
zone            = "us-west3-a"

default_region = "us-west3"
vpc_name       = "karlv-spoke1"

### Add subnets to the list and re-run apply

# Define them
subnets = [
  { name = "subnet-spoke1-us-west1",           region = "us-west1",          ip_cidr_range = "172.30.1.0/24" },
  { name = "subnet-spoke1-us-west2",           region = "us-west2",          ip_cidr_range = "172.30.2.0/24" },
  { name = "subnet-spoke1-us-west3",           region = "us-west3",          ip_cidr_range = "172.30.3.0/24" },
  { name = "subnet-spoke1-us-west4",           region = "us-west4",          ip_cidr_range = "172.30.4.0/24" },
  { name = "subnet-spoke1-us-central1",        region = "us-central1",       ip_cidr_range = "172.30.5.0/24" },
  { name = "subnet-spoke1-us-south1",          region = "us-south1",         ip_cidr_range = "172.30.6.0/24" },
  { name = "subnet-spoke1-us-east1",           region = "us-east1",          ip_cidr_range = "172.30.7.0/24" },
  { name = "subnet-spoke1-us-east4",           region = "us-east4",          ip_cidr_range = "172.30.8.0/24" },
  { name = "subnet-spoke1-us-east5",           region = "us-east5",          ip_cidr_range = "172.30.9.0/24" },
  { name = "subnet-spoke1-europe-west1",       region = "europe-west1",      ip_cidr_range = "172.30.10.0/24" },
  { name = "subnet-spoke1-europe-west2",       region = "europe-west2",      ip_cidr_range = "172.30.11.0/24" },
  { name = "subnet-spoke1-europe-west3",       region = "europe-west3",      ip_cidr_range = "172.30.12.0/24" },
  { name = "subnet-spoke1-europe-west4",       region = "europe-west4",      ip_cidr_range = "172.30.13.0/24" },
  { name = "subnet-spoke1-europe-north1",      region = "europe-north1",     ip_cidr_range = "172.30.14.0/24" },
  { name = "subnet-spoke1-europe-north2",      region = "europe-north2",     ip_cidr_range = "172.30.15.0/24" },
  { name = "subnet-spoke1-europe-central2",    region = "europe-central2",   ip_cidr_range = "172.30.16.0/24" },
  { name = "subnet-spoke1-europe-southwest1",  region = "europe-southwest1", ip_cidr_range = "172.30.17.0/24" },
  { name = "subnet-spoke1-me-central1",        region = "me-central1",       ip_cidr_range = "172.30.18.0/24" },
  { name = "subnet-spoke1-me-central2",        region = "me-central2",       ip_cidr_range = "172.30.19.0/24" },
  { name = "subnet-spoke1-me-west1",           region = "me-west1",          ip_cidr_range = "172.30.20.0/24" },
  { name = "subnet-spoke1-asia-south1",        region = "asia-south1",       ip_cidr_range = "172.30.21.0/24" },
  { name = "subnet-spoke1-asia-south2",        region = "asia-south2",       ip_cidr_range = "172.30.22.0/24" },
  { name = "subnet-spoke1-asia-east1",         region = "asia-east1",        ip_cidr_range = "172.30.23.0/24" },
  { name = "subnet-spoke1-asia-east2",         region = "asia-east2",        ip_cidr_range = "172.30.24.0/24" }
]

### Regions with NAT GW
nat_enabled_regions = [
  "us-west2",
  "us-west3",
  "us-east1",
  "us-east5",
  "europe-west1",
  "europe-north1",
  "me-centra1",
  "asia-east1",
  "asia-south1"
  ]

# Sequential Rnges
/* 
ipv6_cidr_ranges = [
  "2600:1900::/118",
  "2600:1900::400/118",
  "2600:1900::800/118",
  "2600:1900::c00/118",
  "2600:1900::17200/118",
  "2600:1900::1400/118"
] 
*/