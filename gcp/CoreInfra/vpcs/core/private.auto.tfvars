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
  { name = "subnet-hub-us-east5-voc1",      region = "us-east5",          ip_cidr_range = "172.10.9.0/24" },
  { name = "subnet-hub-us-east5-tpu",       region = "us-east5",          ip_cidr_range = "172.10.10.0/29" },
  { name = "subnet-hub-us-east5-tpu2",       region = "us-east5",          ip_cidr_range = "172.10.15.0/29" },
  { name = "subnet-hub-europe-west1",       region = "europe-west1",      ip_cidr_range = "172.20.144.0/20" },
  { name = "subnet-hub-europe-west2",       region = "europe-west2",      ip_cidr_range = "172.20.160.0/20" },
  { name = "subnet-hub-europe-west2-ipv6",  region = "europe-west2",      ip_cidr_range = "192.20.160.0/20", ipv6_cidr_range = "2600:1900::400/118" },
  { name = "subnet-hub-europe-west3",       region = "europe-west3",      ip_cidr_range = "172.20.176.0/20" },
  { name = "subnet-hub-europe-west4",       region = "europe-west4",      ip_cidr_range = "172.20.192.0/20" },
  { name = "subnet-hub-europe-west4-voc1",  region = "europe-west4",      ip_cidr_range = "172.10.11.0/24" },
  { name = "subnet-hub-europe-west4-tpu",   region = "europe-west4",      ip_cidr_range = "172.10.12.0/29" },
  { name = "subnet-hub-europe-north1",      region = "europe-north1",     ip_cidr_range = "172.20.208.0/20" },
  { name = "subnet-hub-europe-north2",      region = "europe-north2",     ip_cidr_range = "172.20.224.0/20" },
  { name = "subnet-hub-europe-central2",    region = "europe-central2",   ip_cidr_range = "172.20.240.0/20" },
  { name = "subnet-hub-europe-southwest1",  region = "europe-southwest1", ip_cidr_range = "172.21.0.0/20" },
  { name = "subnet-hub-me-central1",        region = "me-central1",       ip_cidr_range = "172.21.16.0/20" },
  { name = "subnet-hub-me-central2",        region = "me-central2",       ip_cidr_range = "172.21.32.0/20" },
  { name = "subnet-hub-me-west1",           region = "me-west1",          ip_cidr_range = "172.21.48.0/20" },
  { name = "subnet-hub-asia-south1",        region = "asia-south1",       ip_cidr_range = "172.21.64.0/20" },
  { name = "subnet-hub-asia-south2",        region = "asia-south2",       ip_cidr_range = "172.21.80.0/20" },
  { name = "subnet-hub-asia-northeast1",    region = "asia-northeast1",   ip_cidr_range = "172.21.96.0/20" },
  { name = "subnet-hub-asia-northeast1-voc1",    region = "asia-northeast1",   ip_cidr_range = "172.10.13.0/24" },
  { name = "subnet-hub-asia-northeast1-tpu",     region = "asia-northeast1",   ip_cidr_range = "172.10.14.0/29" },
  { name = "subnet-hub-asia-northeast1-tpu2",     region = "asia-northeast1",   ip_cidr_range = "172.10.18.0/29" },
  { name = "subnet-hub-asia-northeast1-tpu3",     region = "asia-northeast1",   ip_cidr_range = "172.10.16.0/29" },
  { name = "subnet-hub-asia-northeast1-tpu4",     region = "asia-northeast1",   ip_cidr_range = "172.10.17.0/29" },
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
  "europe-west4",
  "europe-north1",
  #"me-centra1",
  #"asia-east1",
  "asia-northeast1",
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





Remapped all your "voc" and "tpu" subnets to the 10.x.x.x space.
Hubs: Unchanged (Safe).
Voc/TPU: Migrated to 10.{RegionID}.{Index}.0/24 pattern.

subnets = [
  # ==========================================
  # US WEST REGIONS
  # ==========================================
  # Hubs (Unchanged - Safe Private 172.20+)
  { name = "subnet-hub-us-west1-01",        region = "us-west1",          ip_cidr_range = "172.20.0.0/20" },
  { name = "subnet-hub-us-west2",           region = "us-west2",          ip_cidr_range = "172.20.16.0/20" },
  { name = "subnet-hub-us-west2-02",        region = "us-west2",          ip_cidr_range = "172.21.128.0/20" },
  { name = "subnet-hub-us-west2-03",        region = "us-west2",          ip_cidr_range = "172.21.144.0/20" },
  { name = "subnet-hub-us-west3",           region = "us-west3",          ip_cidr_range = "172.20.32.0/20" },
  { name = "subnet-hub-us-west4",           region = "us-west4",          ip_cidr_range = "172.20.48.0/20" },

  # Voc (Migrated to 10.1.x for West1, 10.2.x for West2)
  { name = "subnet-hub-us-west1-voc1",      region = "us-west1",          ip_cidr_range = "10.1.1.0/24" },
  { name = "subnet-hub-us-west1-voc2",      region = "us-west1",          ip_cidr_range = "10.1.2.0/24" },
  { name = "subnet-hub-us-west1-voc3",      region = "us-west1",          ip_cidr_range = "10.1.3.0/24" },
  { name = "subnet-hub-us-west1-voc4",      region = "us-west1",          ip_cidr_range = "10.1.4.0/24" },
  
  { name = "subnet-hub-us-west2-voc1",      region = "us-west2",          ip_cidr_range = "10.2.1.0/24" },
  { name = "subnet-hub-us-west2-voc2",      region = "us-west2",          ip_cidr_range = "10.2.2.0/24" },
  { name = "subnet-hub-us-west2-voc3",      region = "us-west2",          ip_cidr_range = "10.2.3.0/24" },
  { name = "subnet-hub-us-west2-voc4",      region = "us-west2",          ip_cidr_range = "10.2.4.0/24" },
  
  # IPv6 (Fixed to null for auto-assignment)
  { name = "subnet-hub-us-west2-ipv6",      region = "us-west2",          ip_cidr_range = "192.20.16.0/20", ipv6_cidr_range = null },

  # ==========================================
  # US CENTRAL REGIONS
  # ==========================================
  # Hubs (Unchanged)
  { name = "subnet-hub-us-central1",        region = "us-central1",       ip_cidr_range = "172.20.64.0/20" },
  
  # Voc (Migrated to 10.3.x)
  { name = "subnet-hub-us-central1-voc1",   region = "us-central1",       ip_cidr_range = "10.3.1.0/24" },
  { name = "subnet-hub-us-central1-voc2",   region = "us-central1",       ip_cidr_range = "10.3.2.0/24" },

  # ==========================================
  # US EAST/SOUTH REGIONS
  # ==========================================
  # Hubs (Unchanged)
  { name = "subnet-hub-us-south1",          region = "us-south1",         ip_cidr_range = "172.20.80.0/20" },
  { name = "subnet-hub-us-east1",           region = "us-east1",          ip_cidr_range = "172.20.96.0/20" },
  { name = "subnet-hub-us-east4",           region = "us-east4",          ip_cidr_range = "172.20.112.0/20" },
  { name = "subnet-hub-us-east5",           region = "us-east5",          ip_cidr_range = "172.20.128.0/20" },

  # Voc (Migrated to 10.4.x for East1, 10.5.x for East5)
  { name = "subnet-hub-us-east1-voc1",      region = "us-east1",          ip_cidr_range = "10.4.1.0/24" },
  { name = "subnet-hub-us-east1-voc2",      region = "us-east1",          ip_cidr_range = "10.4.2.0/24" },
  { name = "subnet-hub-us-east1-voc3",      region = "us-east1",          ip_cidr_range = "10.4.3.0/24" },
  { name = "subnet-hub-us-east1-voc4",      region = "us-east1",          ip_cidr_range = "10.4.4.0/24" },

  { name = "subnet-hub-us-east5-voc1",      region = "us-east5",          ip_cidr_range = "10.5.1.0/24" },
  # TPU (Also migrated to 10.5.x to be safe)
  { name = "subnet-hub-us-east5-tpu",       region = "us-east5",          ip_cidr_range = "10.5.10.0/29" },
  { name = "subnet-hub-us-east5-tpu2",      region = "us-east5",          ip_cidr_range = "10.5.11.0/29" },

  # ==========================================
  # EUROPE REGIONS
  # ==========================================
  # Hubs (Unchanged)
  { name = "subnet-hub-europe-west1",       region = "europe-west1",      ip_cidr_range = "172.20.144.0/20" },
  { name = "subnet-hub-europe-west2",       region = "europe-west2",      ip_cidr_range = "172.20.160.0/20" },
  { name = "subnet-hub-europe-west2-ipv6",  region = "europe-west2",      ip_cidr_range = "192.20.160.0/20", ipv6_cidr_range = null },
  { name = "subnet-hub-europe-west3",       region = "europe-west3",      ip_cidr_range = "172.20.176.0/20" },
  { name = "subnet-hub-europe-west4",       region = "europe-west4",      ip_cidr_range = "172.20.192.0/20" },
  { name = "subnet-hub-europe-north1",      region = "europe-north1",     ip_cidr_range = "172.20.208.0/20" },
  { name = "subnet-hub-europe-north2",      region = "europe-north2",     ip_cidr_range = "172.20.224.0/20" },
  { name = "subnet-hub-europe-central2",    region = "europe-central2",   ip_cidr_range = "172.20.240.0/20" },
  { name = "subnet-hub-europe-southwest1",  region = "europe-southwest1", ip_cidr_range = "172.21.0.0/20" },

  # Voc/TPU (Migrated to 10.6.x for Europe West 4)
  { name = "subnet-hub-europe-west4-voc1",  region = "europe-west4",      ip_cidr_range = "10.6.1.0/24" },
  { name = "subnet-hub-europe-west4-tpu",   region = "europe-west4",      ip_cidr_range = "10.6.10.0/29" },

  # ==========================================
  # ASIA & ME REGIONS
  # ==========================================
  # Hubs (Unchanged)
  { name = "subnet-hub-me-central1",        region = "me-central1",       ip_cidr_range = "172.21.16.0/20" },
  { name = "subnet-hub-me-central2",        region = "me-central2",       ip_cidr_range = "172.21.32.0/20" },
  { name = "subnet-hub-me-west1",           region = "me-west1",          ip_cidr_range = "172.21.48.0/20" },
  { name = "subnet-hub-asia-south1",        region = "asia-south1",       ip_cidr_range = "172.21.64.0/20" },
  { name = "subnet-hub-asia-south2",        region = "asia-south2",       ip_cidr_range = "172.21.80.0/20" },
  { name = "subnet-hub-asia-northeast1",    region = "asia-northeast1",   ip_cidr_range = "172.21.96.0/20" },
  { name = "subnet-hub-asia-east2",         region = "asia-east2",        ip_cidr_range = "172.21.112.0/20" },

  # Voc/TPU (Migrated to 10.7.x for Asia NE 1)
  { name = "subnet-hub-asia-northeast1-voc1", region = "asia-northeast1", ip_cidr_range = "10.7.1.0/24" },
  { name = "subnet-hub-asia-northeast1-tpu",  region = "asia-northeast1", ip_cidr_range = "10.7.10.0/29" },
  { name = "subnet-hub-asia-northeast1-tpu2", region = "asia-northeast1", ip_cidr_range = "10.7.11.0/29" },
  { name = "subnet-hub-asia-northeast1-tpu3", region = "asia-northeast1", ip_cidr_range = "10.7.12.0/29" },
  { name = "subnet-hub-asia-northeast1-tpu4", region = "asia-northeast1", ip_cidr_range = "10.7.13.0/29" },
]

*/