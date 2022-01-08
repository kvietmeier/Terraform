
node_count = 2

# vnet address space
vnet_cidr = ["10.60.0.0/22"]

# Subnets
subnet_cidrs = [
  "10.60.1.0/24",
  "10.60.2.0/24",
]

# for static IPs
nics = [
  "10.60.1.4",
  "10.60.2.4",
  "10.60.1.5",
  "10.60.2.5",
]

# Static IP Allocation
ip_addrs = [
  "10.60.1.4",
  "10.60.2.4",
  "10.60.1.5",
  "10.60.2.5",
]

nic_labels = [
  "primary",
  "internal",
]

subnet_name = [
  "subnet01",
  "subnet02",
]

ip_alloc = [
  "Static",
  "Static",
]

sriov = [
  "false",
  "true",
]


