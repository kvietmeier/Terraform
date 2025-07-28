###========================================================================================###
##  VPC Configuration Overview
##
##  - Configures a custom VPC and defines multiple subnets across regions
##  - Assigns primary and secondary IP ranges to subnets
##  - Enables IPv6 addressing for select subnets
##  - Specifies regions where NAT Gateways are deployed
##
##  NOTE: Only the associated *.tfvars file should be edited to customize this configuration.
###========================================================================================###

## Project Info
project_id      = "clouddev-itdesk124"
region          = "us-west3"
zone            = "us-west3-a"

default_region = "us-west3"
vpc_name       = "karlv-corevpc"

### Add subnets to the list and re-run apply
### Using:  
###    172.20.0.0/20
###    172.21.0.0/20
### For secondary pools - just a few /24s at the beginning
###    172.1.1.0/24
###    172.2.1.0/24
### IPv6 Subnets using - use same as the ipv4 subnet but with 192
###    192.20.0.0/20
###    192.20.16.0/20
###    192.20.32.0/20
###     - etc./

# Define them
subnets = [
  { name = "subnet-hub-us-west1-01",        region = "us-west1",          ip_cidr_range = "172.20.0.0/20" },
  { name = "subnet-hub-us-west1-voc1",      region = "us-west1",          ip_cidr_range = "172.10.1.0/24" },
  { name = "subnet-hub-us-west1-voc2",      region = "us-west1",          ip_cidr_range = "172.10.2.0/24" },
  { name = "subnet-hub-us-west1-voc3",      region = "us-west1",          ip_cidr_range = "172.10.3.0/24" },
  { name = "subnet-hub-us-west1-voc4",      region = "us-west1",          ip_cidr_range = "172.10.4.0/24" },
  { name = "subnet-hub-us-west2",           region = "us-west2",          ip_cidr_range = "172.20.16.0/20" },
  { name = "subnet-hub-us-west2-02",        region = "us-west2",          ip_cidr_range = "172.21.128.0/20" },
  { name = "subnet-hub-us-west2-03",        region = "us-west2",          ip_cidr_range = "172.21.144.0/20" },
  { name = "subnet-hub-us-west2-voc1",      region = "us-west2",          ip_cidr_range = "172.5.1.0/24" },
  { name = "subnet-hub-us-west2-voc2",      region = "us-west2",          ip_cidr_range = "172.6.1.0/24" }, 
  { name = "subnet-hub-us-west2-voc3",      region = "us-west2",          ip_cidr_range = "172.7.1.0/24" }, 
  { name = "subnet-hub-us-west2-voc4",      region = "us-west2",          ip_cidr_range = "172.8.1.0/24" }, 
  { name = "subnet-hub-us-west2-ipv6",      region = "us-west2",          ip_cidr_range = "192.20.16.0/20", ipv6_cidr_range = "2600:1900::/118" },
  { name = "subnet-hub-us-west3",           region = "us-west3",          ip_cidr_range = "172.20.32.0/20" },
  { name = "subnet-hub-us-west4",           region = "us-west4",          ip_cidr_range = "172.20.48.0/20" },
  { name = "subnet-hub-us-central1",        region = "us-central1",       ip_cidr_range = "172.20.64.0/20" },
  { name = "subnet-hub-us-central1-voc1",   region = "us-central1",       ip_cidr_range = "172.9.1.0/24" },
  { name = "subnet-hub-us-central1-voc2",   region = "us-central1",       ip_cidr_range = "172.11.1.0/24" },
  { name = "subnet-hub-us-south1",          region = "us-south1",         ip_cidr_range = "172.20.80.0/20" },
  { name = "subnet-hub-us-east1",           region = "us-east1",          ip_cidr_range = "172.20.96.0/20" },
  { name = "subnet-hub-us-east1-voc1",      region = "us-east1",          ip_cidr_range = "172.10.5.0/24" },
  { name = "subnet-hub-us-east1-voc2",      region = "us-east1",          ip_cidr_range = "172.10.6.0/24" },
  { name = "subnet-hub-us-east1-voc3",      region = "us-east1",          ip_cidr_range = "172.10.7.0/24" },
  { name = "subnet-hub-us-east1-voc4",      region = "us-east1",          ip_cidr_range = "172.10.8.0/24" },
  { name = "subnet-hub-us-east4",           region = "us-east4",          ip_cidr_range = "172.20.112.0/20" },
  { name = "subnet-hub-us-east5",           region = "us-east5",          ip_cidr_range = "172.20.128.0/20" },
  { name = "subnet-hub-europe-west1",       region = "europe-west1",      ip_cidr_range = "172.20.144.0/20" },
  { name = "subnet-hub-europe-west2",       region = "europe-west2",      ip_cidr_range = "172.20.160.0/20" },
  { name = "subnet-hub-europe-west2-ipv6",  region = "europe-west2",      ip_cidr_range = "192.20.160.0/20", ipv6_cidr_range = "2600:1900::400/118" },
  { name = "subnet-hub-europe-west3",       region = "europe-west3",      ip_cidr_range = "172.20.176.0/20" },
  { name = "subnet-hub-europe-west4",       region = "europe-west4",      ip_cidr_range = "172.20.192.0/20" },
  { name = "subnet-hub-europe-north1",      region = "europe-north1",     ip_cidr_range = "172.20.208.0/20" },
  { name = "subnet-hub-europe-north2",      region = "europe-north2",     ip_cidr_range = "172.20.224.0/20" },
  { name = "subnet-hub-europe-central2",    region = "europe-central2",   ip_cidr_range = "172.20.240.0/20" },
  { name = "subnet-hub-europe-southwest1",  region = "europe-southwest1", ip_cidr_range = "172.21.0.0/20" },
  { name = "subnet-hub-me-central1",        region = "me-central1",       ip_cidr_range = "172.21.16.0/20" },
  { name = "subnet-hub-me-central2",        region = "me-central2",       ip_cidr_range = "172.21.32.0/20" },
  { name = "subnet-hub-me-west1",           region = "me-west1",          ip_cidr_range = "172.21.48.0/20" },
  { name = "subnet-hub-asia-south1",        region = "asia-south1",       ip_cidr_range = "172.21.64.0/20" },
  { name = "subnet-hub-asia-south2",        region = "asia-south2",       ip_cidr_range = "172.21.80.0/20" },
  { name = "subnet-hub-asia-east1",         region = "asia-east1",        ip_cidr_range = "172.21.96.0/20" },
  { name = "subnet-hub-asia-east2",         region = "asia-east2",        ip_cidr_range = "172.21.112.0/20" }
]

### Regions with NAT GW
nat_enabled_regions = [
  "us-west1",
  "us-west2",
  "us-west3",
  "us-central1",
  "us-east1",
  "us-east5",
  "europe-west1",
  "europe-north1",
  #"me-centra1",
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