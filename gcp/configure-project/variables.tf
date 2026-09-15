###===================================================================================###
#  Root variables — feature flags + inputs for child modules
#  Source stacks: gcp/CoreInfra/* (left untouched)
###===================================================================================###

variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "us-west2"
}

variable "zone" {
  type    = string
  default = "us-west2-a"
}

###--- Feature flags
variable "enable_firewalls" {
  type    = bool
  default = true
}

variable "enable_dns_private" {
  type    = bool
  default = true
}

variable "enable_dns_ad_forwarder" {
  type    = bool
  default = true
}

variable "enable_dns_vast_forwarders" {
  type    = bool
  default = true
}

variable "enable_vpn" {
  type    = bool
  default = false
}

variable "enable_linux_vms" {
  type    = bool
  default = false
}

variable "enable_windows_vms" {
  type    = bool
  default = false
}

variable "enable_iap" {
  type    = bool
  default = false
}

###--- VPC
variable "vpc_name" {
  type    = string
  default = "karlv-corevpc"
}

variable "subnets" {
  type = list(object({
    name            = string
    region          = string
    ip_cidr_range   = string
    ipv6_cidr_range = optional(string)
    secondary_ip_ranges = optional(list(object({
      range_name    = string
      ip_cidr_range = string
    })))
  }))
}

variable "nat_enabled_regions" {
  type    = list(string)
  default = []
}

###--- Firewalls
variable "firewall" {
  description = "Inputs for the firewalls module"
  type = object({
    description                = optional(string, "Setup common ports and service FW rules for the core VPC")
    myrules_name               = optional(string, "core-firewall-rules")
    addc_name                  = optional(string, "ad-rules")
    vast_rules_name            = optional(string, "vast-rules")
    ingress_filter             = list(string)
    tcp_ports                  = list(string)
    udp_ports                  = list(string)
    spark_tcp                  = list(string)
    spark_vast_tcp             = list(string)
    addc_tcp_ports             = list(string)
    addc_udp_ports             = list(string)
    external_ingress_tcp       = list(string)
    external_ingress_udp       = list(string)
    gcp_service_cidrs          = list(string)
    external_ingress           = list(string)
    enable_deny_public_ingress = optional(bool, true)
  })
  default = {
    ingress_filter = ["10.0.0.0/8", "192.168.0.0/16"]
    tcp_ports      = ["20", "21", "22", "45", "53", "80", "88", "119", "443", "445", "563", "5551", "3389", "5173", "8080"]
    udp_ports      = ["53", "67", "68"]
    spark_tcp      = ["8081", "8481", "8080", "8480", "6066", "7077", "18080", "18480", "4040", "4440", "15002", "4041", "4441", "10000", "10001"]
    spark_vast_tcp = ["9293", "9493", "9292", "9492", "6066", "2424", "18080", "18480", "4040", "4440", "15002", "4041", "4441", "10000", "10001"]
    addc_tcp_ports = ["53", "88", "135", "137", "138", "139", "389", "445", "636", "49152-65535"]
    addc_udp_ports = ["53", "88", "123", "135", "137", "138", "389", "445"]
    external_ingress_tcp = [
      "22", "53", "80", "111", "443", "445", "4420", "5551", "9092", "2049",
      "20048", "20049", "20106", "20107", "20108", "49001", "49002"
    ]
    external_ingress_udp = ["53", "632", "2049", "20048", "20106", "20107", "20108"]
    gcp_service_cidrs = [
      "35.191.0.0/16", "130.211.0.0/22", "199.36.153.4/30",
      "199.36.153.8/30", "35.235.240.0/20", "35.199.192.0/19"
    ]
    external_ingress = []
  }
}

###--- DNS private zone
variable "dns_private" {
  type = object({
    zone_name   = optional(string, "vastclusters")
    dns_name    = string
    description = string
    a_records   = map(list(string))
  })
  default = {
    dns_name    = "arrakis.org."
    description = "VIP Pool IPs"
    a_records   = {}
  }
}

###--- DNS AD forwarder
variable "dns_ad_forwarder" {
  type = object({
    name        = string
    dns_name    = string
    description = string
    # If null, uses the first windows_vms private_ip when enable_windows_vms is true
    fw_target = optional(string)
  })
  default = {
    name        = "ad-forwarding-domain"
    dns_name    = "ginaz.org."
    description = "Forward AD Queries"
    fw_target   = "172.20.16.3"
  }
}

###--- DNS VAST forwarders
variable "dns_vast_forwarders" {
  type = map(object({
    dns_name        = string
    vastcluser_dns  = string
    description     = string
    forwarding_path = optional(string, "private")
  }))
  default = {}
}

###--- VPN
variable "vpn" {
  type = object({
    region           = string
    ha_vpn_gw_name   = string
    router_name      = string
    external_gw_name = string
    gcp_asn          = string
    tunnel_if0       = string
    tunnel_if1       = string
    interface0       = string
    interface1       = string
    gcp_apipa_bgp_a  = string
    gcp_apipa_bgp_b  = string
    bgp_peer_if0     = string
    bgp_peer_if1     = string
    priority         = optional(number, 100)
    shared_key       = string
    azure_pubip0     = string
    azure_pubip1     = string
    azure_apipa_bgp_a = string
    azure_apipa_bgp_b = string
    azure_asn        = string
    advertised_ip_ranges = optional(list(object({
      range       = string
      description = string
    })))
  })
  # Stub used only so count=0 module args type-check; ignored when enable_vpn=false
  default = {
    region            = "europe-north2"
    ha_vpn_gw_name    = "vpn-gateway-azure"
    router_name       = "router-to-azure"
    external_gw_name  = "vpn-gateway-azure-peer"
    gcp_asn           = "65333"
    tunnel_if0        = "vpn-azure-tunnel0"
    tunnel_if1        = "vpn-azure-tunnel1"
    interface0        = "vpn-azure-if0"
    interface1        = "vpn-azure-if1"
    gcp_apipa_bgp_a   = "169.254.21.9"
    gcp_apipa_bgp_b   = "169.254.22.9"
    bgp_peer_if0      = "bgp-azure-peer-if0"
    bgp_peer_if1      = "bgp-azure-peer-if1"
    shared_key        = "CHANGE_ME"
    azure_pubip0      = "0.0.0.0"
    azure_pubip1      = "0.0.0.0"
    azure_apipa_bgp_a = "169.254.21.10"
    azure_apipa_bgp_b = "169.254.22.10"
    azure_asn         = "65010"
  }
}

###--- Linux VMs (map key = logical name)
variable "linux_vms" {
  type = map(object({
    region               = string
    zone                 = string
    vm_name              = string
    machine_type         = optional(string, "e2-medium")
    os_image             = optional(string, "centos-stream-9-v20241009")
    bootdisk_size        = optional(string, "200")
    sa_email             = string
    sa_scopes            = optional(list(string), ["cloud-platform"])
    ssh_user             = string
    ssh_key_file         = string
    cloudinit_configfile = string
    vm_tags              = optional(list(string), [])
    subnet_name          = string
    public_ip_name       = string
    private_ip_name      = string
    private_ip           = string
    assign_public_ip     = optional(bool, true)
  }))
  default = {}
}

###--- Windows VMs
variable "windows_vms" {
  type = map(object({
    region                 = string
    zone                   = string
    vm_name                = string
    machine_type           = optional(string, "c2-standard-4")
    os_image               = optional(string, "windows-server-2022-dc-v20241115")
    bootdisk_size          = optional(string, "400")
    sa_email               = string
    sa_scopes              = optional(list(string), ["cloud-platform"])
    windows_sysprep_script = string
    vm_tags                = optional(list(string), [])
    subnet_name            = string
    public_ip_name         = string
    private_ip_name        = string
    private_ip             = string
    assign_public_ip       = optional(bool, true)
  }))
  default = {}
}

###--- IAP
variable "iap_user_emails" {
  type    = list(string)
  default = []
}
