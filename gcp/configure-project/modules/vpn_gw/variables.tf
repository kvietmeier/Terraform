variable "region" {
  type = string
}

variable "network" {
  description = "VPC network name or self_link"
  type        = string
}

variable "ha_vpn_gw_name" {
  type = string
}

variable "router_name" {
  type = string
}

variable "external_gw_name" {
  type = string
}

variable "gcp_asn" {
  type = string
}

variable "tunnel_if0" {
  type = string
}

variable "tunnel_if1" {
  type = string
}

variable "interface0" {
  type = string
}

variable "interface1" {
  type = string
}

variable "gcp_apipa_bgp_a" {
  type = string
}

variable "gcp_apipa_bgp_b" {
  type = string
}

variable "bgp_peer_if0" {
  type = string
}

variable "bgp_peer_if1" {
  type = string
}

variable "priority" {
  type    = number
  default = 100
}

variable "shared_key" {
  type      = string
  sensitive = true
}

variable "azure_pubip0" {
  type = string
}

variable "azure_pubip1" {
  type = string
}

variable "azure_apipa_bgp_a" {
  type = string
}

variable "azure_apipa_bgp_b" {
  type = string
}

variable "azure_asn" {
  type = string
}

variable "advertised_ip_ranges" {
  description = "Extra CIDRs to advertise over BGP (e.g. VIP pools)"
  type = list(object({
    range       = string
    description = string
  }))
  default = [
    { range = "33.20.1.0/24", description = "Protocols Pool" },
    { range = "33.21.1.0/24", description = "Replication Pool" },
  ]
}
