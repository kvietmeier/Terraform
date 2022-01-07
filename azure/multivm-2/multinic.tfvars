
node_count = 2

# vnet address space
vnet_prefix = ["10.60.0.0/22"]

# Subnets
subnet_prefixes = [
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
